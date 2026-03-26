import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/config.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../favorites/domain/factories/favorite_factory.dart';
import '../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../domain/modals/tile_url.dart';

final urlTileProvider = ChangeNotifierProvider((ref) => UrlTileProvider());

class UrlTileProvider extends ChangeNotifier {
  late GlobalKey webViewKey;
  final isFavorite = StateProvider<bool>((ref) => false);
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
    allowsLinkPreview: false,
    builtInZoomControls: false,
  );

  PullToRefreshController? pullToRefreshController;

  final isLoading = StateProvider<bool>((ref) => false);
  final canGoBack = StateProvider<bool>((ref) => false);
  final canGoForward = StateProvider<bool>((ref) => false);

  Future<void> initUrlTile(WidgetRef ref, String url) async {
    ref.read(isLoading.notifier).state = true;
    ref.read(canGoBack.notifier).state = false;
    ref.read(canGoForward.notifier).state = false;

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await webViewController?.reload();
        } else if (Platform.isIOS) {
          await webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );

    notifyListeners();
  }

  void setWebViewController(WidgetRef ref, InAppWebViewController controller) {
    webViewController = controller;
    notifyListeners();
  }

  void onLoadStart(WidgetRef ref, WebUri? url) {
    ref.read(isLoading.notifier).state = true;

    _updateNavigationState(ref);
    notifyListeners();
  }

  void onReceivedError(WidgetRef ref, WebResourceError error) {
    pullToRefreshController?.endRefreshing();
    ref.read(isLoading.notifier).state = false;

    debugPrint('WebView Error: ${error.description}');
    notifyListeners();
  }

  void onProgressChanged(WidgetRef ref, int progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
      ref.read(isLoading.notifier).state = false;
    }

    _updateNavigationState(ref);
    notifyListeners();
  }

  void onUpdateVisitedHistory(WidgetRef ref, WebUri? url) {
    _updateNavigationState(ref);
    notifyListeners();
  }

  Future<NavigationActionPolicy> shouldOverrideUrlLoading(NavigationAction navigationAction) async {
    final uri = navigationAction.request.url!;

    if (!['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about'].contains(uri.scheme)) {
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<void> _updateNavigationState(WidgetRef ref) async {
    if (webViewController != null) {
      try {
        final canBack = await webViewController!.canGoBack();
        final canForward = await webViewController!.canGoForward();

        ref.read(canGoBack.notifier).state = canBack;
        ref.read(canGoForward.notifier).state = canForward;
      } catch (e) {
        debugPrint("Erreur lors de la mise à jour de l'état de navigation: $e");
      }
    }
  }

  Future<void> onPressFavorite(WidgetRef ref, String url) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final favorite = FavoriteFactory.fromTileUrl(
      TileUrl(
        id: url,
        idProject: ProdConfig().projectId,
        type: 'Tuile via une URL',
        slug: 'fo_tul',
        results: TileUrlResults(
          titleTile: 'Tuile Url manuel',
          typeLink: '2',
          tile: '0',
          urlTile: url,
          publishTile: true,
        ),
      ),
    );
    final currentIsFavorite = ref.read(isFavorite);

    ref.read(isFavorite.notifier).state = !currentIsFavorite;

    try {
      final result = currentIsFavorite ? await useCase.removeFromFavorites(favorite.id) : await useCase.addToFavorites(favorite);

      await result.fold(
        (error) async {
          ref.read(isFavorite.notifier).state = currentIsFavorite;
          Helpers.showSnackBar(ref.context, 'Erreur: $error', Colors.red);
        },
        (success) async {
          ref.read(updateFavorites.notifier).state = !ref.read(updateFavorites);

          final message = !currentIsFavorite ? 'Ajouté aux favoris' : 'Supprimé des favoris';
          Helpers.showSnackBar(ref.context, message, Colors.green);
        },
      );
    } catch (e) {
      ref.read(isFavorite.notifier).state = currentIsFavorite;
      if (ref.context.mounted) {
        Helpers.showSnackBar(ref.context, 'Erreur inattendue: $e', Colors.red);
      }
    }
  }

  @override
  void dispose() {
    webViewController = null;
    pullToRefreshController = null;
    super.dispose();
  }
}
