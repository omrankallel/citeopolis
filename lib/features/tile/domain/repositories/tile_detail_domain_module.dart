import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tile_detail_data_module.dart';
import '../usecases/tile_detail_use_case.dart';
import '../usecases/tile_detail_use_case_impl.dart';

final tileDetailUseCaseProvider = Provider<TileDetailUseCase>(
  (ref) => TileDetailUseCaseImpl(ref.watch(tileDetailRepositoryProvider)),
);
