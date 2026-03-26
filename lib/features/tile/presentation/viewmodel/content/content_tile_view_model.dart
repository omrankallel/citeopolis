import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/helpers.dart';
import '../../../../favorites/domain/factories/favorite_factory.dart';
import '../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../domain/modals/tile_content.dart';

final contentTileProvider = ChangeNotifierProvider((ref) => ContentTileProvider());

class ContentTileProvider extends ChangeNotifier {

  final tileContent = StateProvider<TileContent>((ref) => TileContent());
  final contentFiltered = StateProvider<TileContent?>((ref) => null);
  final hasSearchResults = StateProvider<bool>((ref) => false);

  final isFavorite = StateProvider<bool>((ref) => false);

  TileContent? _originalContent;

  Future<void> initContentTile(WidgetRef ref, TileContent tileContent) async {
    ref.read(ref.watch(homeProvider).searchText.notifier).state = '';
    ref.watch(homeProvider).searchController.clear();

    ref.read(this.tileContent.notifier).state = tileContent;
    ref.read(contentFiltered.notifier).state = tileContent;
    ref.read(hasSearchResults.notifier).state = false;

    _originalContent = tileContent;
    notifyListeners();
  }

  bool _matchesSearchQuery(TileContent tileContent, String query) {
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      tileContent.results!.titleTile,
      tileContent.results!.descTile,
      tileContent.results!.contentTile,
    ].where((field) => (field ?? '').isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field ?? '';

        if (field == (tileContent.results?.contentTile ?? '')) {
          fieldContent = _cleanHtmlContent(field ?? '');
        } else {
          fieldContent = (field ?? '').toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }
      }

      if (!termFound) {
        return false;
      }
    }

    return true;
  }

  String _cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return '';
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'&\w+;'), ' ').trim().toLowerCase();
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    final normalizedText = text.trim().toLowerCase();

    ref.read(ref.watch(homeProvider).searchText.notifier).state = normalizedText;

    if (normalizedText.isEmpty) {
      ref.read(contentFiltered.notifier).state = _originalContent;
      ref.read(hasSearchResults.notifier).state = false;
      ref.watch(homeProvider).searchController.clear();
      notifyListeners();
      return;
    }

    if (_originalContent != null) {
      final hasMatches = _matchesSearchQuery(_originalContent!, normalizedText);

      if (hasMatches) {
        ref.read(contentFiltered.notifier).state = _originalContent;
        ref.read(hasSearchResults.notifier).state = true;
      } else {
        ref.read(contentFiltered.notifier).state = null;
        ref.read(hasSearchResults.notifier).state = false;
      }

      notifyListeners();
    }
  }

  void clearSearch(WidgetRef ref) {
    ref.read(ref.watch(homeProvider).searchText.notifier).state = '';
    ref.read(contentFiltered.notifier).state = _originalContent;
    ref.read(hasSearchResults.notifier).state = false;
    ref.watch(homeProvider).searchController.clear();
    notifyListeners();
  }

  String getSearchQuery(WidgetRef ref) => ref.read(ref.watch(homeProvider).searchText);

  bool hasResults(WidgetRef ref) => ref.read(hasSearchResults);

  TileContent? getFilteredContent(WidgetRef ref) => ref.read(contentFiltered);

  int getResultsCount(WidgetRef ref) {
    final query = ref.read(ref.watch(homeProvider).searchText);
    if (query.isEmpty) return 0;

    final filtered = ref.read(contentFiltered);
    return filtered != null ? 1 : 0;
  }
  Future<void> onPressFavorite(WidgetRef ref, TileContent tileContent) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final favorite = FavoriteFactory.fromTileContent(tileContent);
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

}
