import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/image_app/image_service.dart';
import '../../../../core/services/image_app/image_service_impl.dart';
import '../../domain/repositories/preloader_repository.dart';
import '../service/preloader_service.dart';
import '../service/preloader_service_impl.dart';
import 'preloader_repository_impl.dart';

final preloaderProvider = Provider<PreloaderService>((_) => PreloaderServiceImpl());
final imageServiceProvider = Provider<ImageService>((_) => ImageServiceImpl());

final preloaderRepositoryProvider = Provider<PreloaderRepository>(
  (ref) => PreloaderRepositoryImpl(
    ref.watch(preloaderProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(imageServiceProvider),
  ),
);
