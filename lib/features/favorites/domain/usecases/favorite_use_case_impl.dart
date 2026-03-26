import 'package:dartz/dartz.dart';

import '../modals/favorite.dart';
import '../repositories/favorite_repository.dart';
import 'favorite_use_case.dart';

class FavoriteUseCaseImpl implements FavoriteUseCase {
  final FavoriteRepository _repository;

  const FavoriteUseCaseImpl(this._repository);

  @override
  Future<Either<String, bool>> addToFavorites(Favorite favorite) => _repository.addToFavorites(favorite);

  @override
  Future<Either<String, bool>> removeFromFavorites(String id) => _repository.removeFromFavorites(id);

  @override
  Future<Either<String, List<Favorite>>> getAllFavorites() => _repository.getAllFavorites();

  @override
  Future<Either<String, List<Favorite>>> getFavoritesByType(String type) => _repository.getFavoritesByType(type);

  @override
  Future<Either<String, List<Favorite>>> searchFavorites(String query) => _repository.searchFavorites(query);

  @override
  Future<Either<String, bool>> clearAllFavorites() => _repository.clearAllFavorites();

  @override
  bool isFavorite(String id) => _repository.isFavorite(id);

  @override
  Favorite? getFavorite(String id) => _repository.getFavorite(id);

  @override
  int getFavoritesCount() => _repository.getFavoritesCount();

  @override
  Future<Either<String, bool>> toggleFavorite(Favorite favorite) async {
    final isCurrentlyFavorite = _repository.isFavorite(favorite.id);

    if (isCurrentlyFavorite) {
      return await _repository.removeFromFavorites(favorite.id);
    } else {
      return await _repository.addToFavorites(favorite);
    }
  }
}
