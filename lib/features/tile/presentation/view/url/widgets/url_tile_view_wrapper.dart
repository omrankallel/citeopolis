import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../design_system/atoms/atom_floating_action_button_favorite.dart';
import '../../../../../../router/navigation_service.dart';
import '../../../../../../router/routes.dart';
import '../../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../viewmodel/url/url_tile_view_model.dart';

class UrlTileViewWrapper extends ConsumerStatefulWidget {
  final bool withScaffold;
  final String url;
  final bool isTile;

  const UrlTileViewWrapper({
    required this.withScaffold,
    required this.url,
    this.isTile = true,
    super.key,
  });

  @override
  ConsumerState<UrlTileViewWrapper> createState() => _UrlTileViewWrapperState();
}

class _UrlTileViewWrapperState extends ConsumerState<UrlTileViewWrapper> {
  bool _isInitialized = false;
  late GlobalKey _webViewKey;

  @override
  void initState() {
    super.initState();
    _webViewKey = GlobalKey(debugLabel: '${widget.url}_${widget.hashCode}_${DateTime.now().millisecondsSinceEpoch}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    if (_isInitialized) return;

    try {
      final urlTileViewModel = ref.read(urlTileProvider);
      urlTileViewModel.webViewKey = _webViewKey;
      await urlTileViewModel.initUrlTile(ref, widget.url);
      if (widget.isTile) {
        ref.read(urlTileViewModel.isFavorite.notifier).state = isFavorite();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation de la WebView: \$e");
    }
  }

  bool isFavorite() {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = 'tile_url_${widget.url}';

    final isFavorite = useCase.isFavorite(favoriteId);
    return isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final urlTileViewModel = ref.watch(urlTileProvider);

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFCA542B)),
              16.ph,
              Text(
                'Chargement de la page web...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.withScaffold) {
      return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          drawerEnableOpenDragGesture: false,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            scrolledUnderElevation: 0,
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  NavigationService.back(context, ref);
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
              ),
            ),
            actions: widget.isTile
                ? [
                    NotificationIconBadge(
                      iconData: Icons.notifications_none_sharp,
                      onTap: () => NavigationService.push(context, ref, Paths.notifications),
                    ),
                    25.pw,
                    InkWell(
                      onTap: () {},
                      child: const bg.Badge(
                        showBadge: false,
                        child: WidgetPopupMenu(),
                      ),
                    ),
                    20.pw,
                  ]
                : null,
          ),
          body: _buildWebViewContent(context, urlTileViewModel, isDarkMode),
          floatingActionButton: widget.isTile
              ? _buildFloatingActionButton(
                  onPressed: () => urlTileViewModel.onPressFavorite(ref, widget.url),
                  isDarkMode: isDarkMode,
                  isFavorite: ref.watch(urlTileViewModel.isFavorite),
                )
              : null,
        ),
      );
    } else {
      return Stack(
        children: [
          _buildWebViewContent(context, urlTileViewModel, isDarkMode),
          if (widget.isTile)
            _buildFloatingActionButton(
              onPressed: () => urlTileViewModel.onPressFavorite(ref, widget.url),
              isDarkMode: isDarkMode,
              isFavorite: ref.watch(urlTileViewModel.isFavorite),
              isPositioned: true,
            ),
        ],
      );
    }
  }

  Widget _buildWebViewContent(BuildContext context, UrlTileProvider urlTileViewModel, bool isDarkMode) => Column(
        children: [
          Expanded(
            child: _buildWebView(context, urlTileViewModel, isDarkMode),
          ),
        ],
      );

  Widget _buildWebView(BuildContext context, UrlTileProvider urlTileViewModel, bool isDarkMode) {
    final isLoading = ref.watch(urlTileViewModel.isLoading);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: _webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri(widget.url),
                ),
                initialSettings: urlTileViewModel.settings,
                pullToRefreshController: urlTileViewModel.pullToRefreshController,
                onWebViewCreated: (controller) {
                  urlTileViewModel.setWebViewController(ref, controller);
                },
                onLoadStart: (controller, url) {
                  urlTileViewModel.onLoadStart(ref, url);
                },
                onPermissionRequest: (controller, request) async => PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                ),
                shouldOverrideUrlLoading: (controller, navigationAction) async => urlTileViewModel.shouldOverrideUrlLoading(navigationAction),
                onReceivedError: (controller, request, error) {
                  urlTileViewModel.onReceivedError(ref, error);
                },
                onProgressChanged: (controller, progress) {
                  urlTileViewModel.onProgressChanged(ref, progress);
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  urlTileViewModel.onUpdateVisitedHistory(ref, url);
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('Console: \${consoleMessage.message}');
                },
                onJsAlert: (controller, jsAlertRequest) async {
                  await _showJsAlert(context, jsAlertRequest);
                  return JsAlertResponse(handledByClient: true);
                },
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFCA542B),
                  ),
                ),
            ],
          ),
        ),

        // Barre de navigation
        _buildNavigationBar(urlTileViewModel, isDarkMode),
      ],
    );
  }

  Widget _buildNavigationBar(UrlTileProvider urlTileViewModel, bool isDarkMode) {
    final canGoBack = ref.watch(urlTileViewModel.canGoBack);
    final canGoForward = ref.watch(urlTileViewModel.canGoForward);
    final isLoading = ref.watch(urlTileViewModel.isLoading);

    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: canGoBack ? () => urlTileViewModel.webViewController?.goBack() : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: canGoBack ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: canGoForward ? () => urlTileViewModel.webViewController?.goForward() : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: canGoForward ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: isLoading ? () => urlTileViewModel.webViewController?.stopLoading() : () => urlTileViewModel.webViewController?.reload(),
            icon: Icon(
              isLoading ? Icons.stop : Icons.refresh,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showJsAlert(BuildContext context, JsAlertRequest jsAlertRequest) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert'),
        content: Text(jsAlertRequest.message ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({required VoidCallback onPressed, required bool isDarkMode, required bool isFavorite, bool isPositioned = false}) {
    final buttonColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'urlTileViewWrapper_${widget.url}_${widget.hashCode}',
          // HeroTag unique
          onPressed: onPressed,
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
        if (!isPositioned) 50.ph,
      ],
    );
    if (isPositioned) {
      return Positioned(
        right: 10,
        bottom: 50,
        child: buttonColumn,
      );
    }

    return buttonColumn;
  }
}
