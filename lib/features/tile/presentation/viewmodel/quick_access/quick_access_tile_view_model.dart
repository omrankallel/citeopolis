import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/helpers.dart';
import '../../../../favorites/domain/factories/favorite_factory.dart';
import '../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../domain/modals/tile_quick_access.dart';

final quickAccessTileProvider = ChangeNotifierProvider((ref) => QuickAccessTileProvider());

class QuickAccessTileProvider extends ChangeNotifier {

  final tileQuickAccess = StateProvider<TileQuickAccess>((ref) => TileQuickAccess());
  final quickAccessFiltered = StateProvider<TileQuickAccess?>((ref) => null);
  final hasSearchResults = StateProvider<bool>((ref) => false);
  final isFavorite = StateProvider<bool>((ref) => false);

  TileQuickAccess? _originalQuickAccess;

  Future<void> initQuickAccessTile(WidgetRef ref, TileQuickAccess tileQuickAccess) async {
    ref.read(ref.watch(homeProvider).searchText.notifier).state = '';
    ref.watch(homeProvider).searchController.clear();

    ref.read(this.tileQuickAccess.notifier).state = tileQuickAccess;
    ref.read(quickAccessFiltered.notifier).state = tileQuickAccess;
    ref.read(hasSearchResults.notifier).state = false;

    _originalQuickAccess = tileQuickAccess;
    notifyListeners();
  }

  bool _matchesSearchQueryInData(QuickAccessData data, String query) {
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      data.title?.toLowerCase() ?? '',
      data.secondaryTitle?.toLowerCase() ?? '',
      data.urlLink?.toLowerCase() ?? '',
      data.tile?.toLowerCase() ?? '',
    ];

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        if (field.contains(term.toLowerCase())) {
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


  TileQuickAccess? _filterQuickAccessData(TileQuickAccess original, String query) {
    if (original.results?.data == null) return null;

    final filteredData = original.results!.data!
        .where((data) => _matchesSearchQueryInData(data, query))
        .toList();

    if (filteredData.isEmpty) return null;

    return original.copyWith(
      results: original.results!.copyWith(
        data: filteredData,
      ),
    );
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    final normalizedText = text.trim().toLowerCase();

    ref.read(ref.watch(homeProvider).searchText.notifier).state = normalizedText;

    if (normalizedText.isEmpty) {
      ref.read(quickAccessFiltered.notifier).state = _originalQuickAccess;
      ref.read(hasSearchResults.notifier).state = false;
      notifyListeners();
      return;
    }

    if (_originalQuickAccess != null) {
      // Filtrer les données selon la recherche
      final filteredQuickAccess = _filterQuickAccessData(_originalQuickAccess!, normalizedText);

      if (filteredQuickAccess != null) {
        ref.read(quickAccessFiltered.notifier).state = filteredQuickAccess;
        ref.read(hasSearchResults.notifier).state = true;
      } else {
        ref.read(quickAccessFiltered.notifier).state = TileQuickAccess(
          results: TileQuickAccessResults(data: []),
        );
        ref.read(hasSearchResults.notifier).state = false;
      }

      notifyListeners();
    }
  }

  void clearSearch(WidgetRef ref) {
    ref.read(ref.watch(homeProvider).searchText.notifier).state = '';
    ref.read(quickAccessFiltered.notifier).state = _originalQuickAccess;
    ref.read(hasSearchResults.notifier).state = false;
    ref.watch(homeProvider).searchController.clear();
    notifyListeners();
  }

  String getSearchQuery(WidgetRef ref) => ref.read(ref.watch(homeProvider).searchText);

  bool hasResults(WidgetRef ref) => ref.read(hasSearchResults);

  TileQuickAccess? getFilteredContent(WidgetRef ref) => ref.read(quickAccessFiltered);

  int getResultsCount(WidgetRef ref) {
    final query = ref.read(ref.watch(homeProvider).searchText);
    if (query.isEmpty) {
      return _originalQuickAccess?.results?.data?.length ?? 0;
    }

    final filtered = ref.read(quickAccessFiltered);
    return filtered?.results?.data?.length ?? 0;
  }

  Future<void> onPressFavorite(WidgetRef ref, TileQuickAccess tileQuickAccess) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final favorite = FavoriteFactory.fromTileQuickAccess(tileQuickAccess);
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