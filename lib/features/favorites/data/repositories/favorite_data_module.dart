import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/favorite_repository.dart';
import '../service/favorite_service.dart';
import '../service/favorite_service_impl.dart';
import 'favorite_repository_impl.dart';

final favoriteServiceProvider = Provider<FavoriteService>((_) => FavoriteServiceImpl());

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepositoryImpl(
    ref.watch(favoriteServiceProvider),
  ),
);
