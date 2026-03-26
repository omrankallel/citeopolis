import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../domain/modals/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../service/favorite_service.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteService _favoriteService;

  FavoriteRepositoryImpl(this._favoriteService);

  @override
  Future<Either<String, bool>> addToFavorites(Favorite favorite) async {
    try {
      return await _favoriteService.addToFavorites(favorite);
    } catch (e) {
      debugPrint("Erreur dans le repository lors de l'ajout aux favoris: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> removeFromFavorites(String id) async {
    try {
      return await _favoriteService.removeFromFavorites(id);
    } catch (e) {
      debugPrint('Erreur dans le repository lors de la suppression des favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favorite>>> getAllFavorites() async {
    try {
      final result = await _favoriteService.getAllFavorites();
      return result.fold(
        (error) => Left(error),
        (favorites) => Right(favorites),
      );
    } catch (e) {
      debugPrint('Erreur dans le repository lors de la récupération des favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favorite>>> getFavoritesByType(String type) async {
    try {
      final result = await _favoriteService.getFavoritesByType(type);
      return result.fold(
        (error) => Left(error),
        (favorites) => Right(favorites),
      );
    } catch (e) {
      debugPrint('Erreur dans le repository lors de la récupération des favoris par type: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favorite>>> searchFavorites(String query) async {
    try {
      final result = await _favoriteService.searchFavorites(query);
      return result.fold(
        (error) => Left(error),
        (favorites) => Right(favorites),
      );
    } catch (e) {
      debugPrint('Erreur dans le repository lors de la recherche de favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> clearAllFavorites() async {
    try {
      return await _favoriteService.clearAllFavorites();
    } catch (e) {
      debugPrint('Erreur dans le repository lors du nettoyage des favoris: $e');
      return Left(e.toString());
    }
  }

  @override
  bool isFavorite(String id) {
    try {
      return _favoriteService.isFavorite(id);
    } catch (e) {
      debugPrint('Erreur dans le repository lors de la vérification du favori: $e');
      return false;
    }
  }

  @override
  Favorite? getFavorite(String id) {
    try {
      final favorite = _favoriteService.getFavorite(id);
      return favorite;
    } catch (e) {
      debugPrint('Erreur dans le repository lors de la récupération du favori: $e');
      return null;
    }
  }

  @override
  int getFavoritesCount() {
    try {
      return _favoriteService.getFavoritesCount();
    } catch (e) {
      debugPrint('Erreur dans le repository lors du comptage des favoris: $e');
      return 0;
    }
  }
}
