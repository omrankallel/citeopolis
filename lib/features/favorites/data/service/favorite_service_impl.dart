import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../../../core/services/injector.dart';
import '../../domain/modals/favorite.dart';
import 'favorite_service.dart';

class FavoriteServiceImpl implements FavoriteService {
  static const String _storageKey = 'favorites_list';

  final LocalStorageListService<Favorite> _favoriteStorage = getIt<LocalStorageListService<Favorite>>();

  @override
  Future<Either<String, bool>> addToFavorites(Favorite favorite) async {
    try {
      final currentFavorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];

      final existingIndex = currentFavorites.indexWhere((f) => f.id == favorite.id);

      if (existingIndex != -1) {
        currentFavorites[existingIndex] = favorite.copyWith(updatedAt: DateTime.now());
      } else {
        currentFavorites.add(favorite);
      }

      await _favoriteStorage.save(_storageKey, currentFavorites);

      debugPrint('✅ Favori ajouté: ${favorite.title}');
      return const Right(true);
    } catch (e) {
      debugPrint("❌ Erreur lors de l'ajout aux favoris: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> removeFromFavorites(String id) async {
    try {
      final currentFavorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];
      final updatedFavorites = currentFavorites.where((favorite) => favorite.id != id).toList();

      await _favoriteStorage.save(_storageKey, updatedFavorites);

      debugPrint('✅ Favori supprimé: $id');
      return const Right(true);
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression des favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favorite>>> getAllFavorites() async {
    try {
      final favorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(favorites);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favorite>>> getFavoritesByType(String type) async {
    try {
      final allFavorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];
      final favorites = allFavorites.where((favorite) => favorite.type == type).toList();
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(favorites);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des favoris par type: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favorite>>> searchFavorites(String query) async {
    try {
      final allFavorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];

      if (query.isEmpty) {
        return Right(allFavorites);
      }

      final lowercaseQuery = query.toLowerCase();
      final favorites = allFavorites
          .where(
            (favorite) => favorite.title.toLowerCase().contains(lowercaseQuery) || (favorite.subtitle?.toLowerCase().contains(lowercaseQuery) ?? false),
          )
          .toList();
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(favorites);
    } catch (e) {
      debugPrint('❌ Erreur lors de la recherche de favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> clearAllFavorites() async {
    try {
      await _favoriteStorage.delete(_storageKey);

      debugPrint('🧹 Tous les favoris ont été supprimés');
      return const Right(true);
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage des favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  bool isFavorite(String id) {
    try {
      if (!_favoriteStorage.isInitialized) {
        return false;
      }

      final favorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];
      return favorites.any((favorite) => favorite.id == id);
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du favori: $e');
      return false;
    }
  }

  @override
  Favorite? getFavorite(String id) {
    try {
      if (!_favoriteStorage.isInitialized) {
        return null;
      }

      final favorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];
      final favorite = favorites.firstWhere(
        (f) => f.id == id,
        orElse: () => throw StateError('Favori non trouvé'),
      );

      return favorite;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du favori: $e');
      return null;
    }
  }

  @override
  int getFavoritesCount() {
    try {
      if (!_favoriteStorage.isInitialized) {
        return 0;
      }

      final favorites = _favoriteStorage.get(_storageKey) ?? <Favorite>[];
      return favorites.length;
    } catch (e) {
      debugPrint('❌ Erreur lors du comptage des favoris: $e');
      return 0;
    }
  }
}
