import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../domain/repositories/tile_repository.dart';
import '../service/tile_detail_service.dart';
import '../service/tile_detail_service_impl.dart';
import '../service/tile_service.dart';
import '../service/tile_service_impl.dart';
import 'tile_detail_repository_impl.dart';
import 'tile_repository_impl.dart';

final tileProvider = Provider<TileService>((_) => TileServiceImpl());
final tileDetailServiceProvider = Provider<TileDetailService>((_) => TileDetailServiceImpl());

final tileRepositoryProvider = Provider<TileRepository>(
  (ref) => TileRepositoryImpl(
    ref.watch(tileProvider),
    TileDetailRepositoryImpl(
      ref.watch(tileDetailServiceProvider),
      ref.watch(connectivityServiceProvider),
    ),
    ref.watch(connectivityServiceProvider),
  ),
);
