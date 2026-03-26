import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/favorite_data_module.dart';
import '../usecases/favorite_use_case.dart';
import '../usecases/favorite_use_case_impl.dart';

final favoriteUseCaseProvider = Provider<FavoriteUseCase>(
  (ref) => FavoriteUseCaseImpl(ref.watch(favoriteRepositoryProvider)),
);

final updateFavorites = StateProvider<bool>((ref) => false);
final selectedFavoriteType = StateProvider<String?>((ref) => null);
final favoriteSearchQuery = StateProvider<String>((ref) => '');

final favoritesCountProvider = FutureProvider<int>((ref) async {
  final useCase = ref.watch(favoriteUseCaseProvider);
  return useCase.getFavoritesCount();
});

final allFavoritesProvider = FutureProvider((ref) async {
  final useCase = ref.watch(favoriteUseCaseProvider);

  ref.watch(updateFavorites);

  final result = await useCase.getAllFavorites();
  return result.fold(
    (error) => throw Exception(error),
    (favorites) => favorites,
  );
});

final favoritesByTypeProvider = FutureProvider.family<List<dynamic>, String>((ref, type) async {
  final useCase = ref.watch(favoriteUseCaseProvider);
  ref.watch(updateFavorites);

  final result = await useCase.getFavoritesByType(type);
  return result.fold(
    (error) => throw Exception(error),
    (favorites) => favorites,
  );
});

final searchFavoritesProvider = FutureProvider((ref) async {
  final useCase = ref.watch(favoriteUseCaseProvider);
  final query = ref.watch(favoriteSearchQuery);
  ref.watch(updateFavorites);

  final result = await useCase.searchFavorites(query);
  return result.fold(
    (error) => throw Exception(error),
    (favorites) => favorites,
  );
});
