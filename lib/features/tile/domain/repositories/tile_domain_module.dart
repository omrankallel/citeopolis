import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tile_data_module.dart';
import '../usecases/tile_use_case.dart';
import '../usecases/tile_use_case_impl.dart';

final tileUseCaseProvider = Provider<TileUseCase>(
  (ref) => TileUseCaseImpl(ref.watch(tileRepositoryProvider)),
);

final updateTile = StateProvider<bool>((ref) => false);
final idTile = StateProvider<int>((ref) => -1);
final updateDetailTileQuickAccess = StateProvider<bool>((ref) => false);
