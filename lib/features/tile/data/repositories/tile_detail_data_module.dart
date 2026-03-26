import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/image_app/image_service.dart';
import '../../../../core/services/image_app/image_service_impl.dart';
import '../../domain/repositories/tile_detail_repository.dart';
import '../../domain/usecases/tile_detail_use_case.dart';
import '../../domain/usecases/tile_detail_use_case_impl.dart';
import '../repositories/tile_detail_repository_impl.dart';
import '../service/tile_detail_service.dart';
import '../service/tile_detail_service_impl.dart';

final tileDetailServiceProvider = Provider<TileDetailService>((_) => TileDetailServiceImpl());
final imageServiceProvider = Provider<ImageService>((_) => ImageServiceImpl());

final tileDetailRepositoryProvider = Provider<TileDetailRepository>(
  (ref) => TileDetailRepositoryImpl(
    ref.watch(tileDetailServiceProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(imageServiceProvider),
  ),
);

final tileDetailUseCaseProvider = Provider<TileDetailUseCase>(
  (ref) => TileDetailUseCaseImpl(ref.watch(tileDetailRepositoryProvider)),
);
