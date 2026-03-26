import 'package:dartz/dartz.dart';

import '../../domain/modals/favorite.dart';

abstract class FavoriteService {
  Future<Either<String, bool>> addToFavorites(Favorite favorite);

  Future<Either<String, bool>> removeFromFavorites(String id);

  Future<Either<String, List<Favorite>>> getAllFavorites();

  Future<Either<String, List<Favorite>>> getFavoritesByType(String type);

  Future<Either<String, List<Favorite>>> searchFavorites(String query);

  Future<Either<String, bool>> clearAllFavorites();

  bool isFavorite(String id);

  Favorite? getFavorite(String id);

  int getFavoritesCount();
}
