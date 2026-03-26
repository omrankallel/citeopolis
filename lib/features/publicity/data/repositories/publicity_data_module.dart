import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/image_app/image_service.dart';
import '../../../../core/services/image_app/image_service_impl.dart';
import '../../domain/repositories/publicity_repository.dart';
import '../service/publicity_service.dart';
import '../service/publicity_service_impl.dart';
import 'publicity_repository_impl.dart';

final publicityProvider = Provider<PublicityService>((_) => PublicityServiceImpl());
final imageServiceProvider = Provider<ImageService>((_) => ImageServiceImpl());

final publicityRepositoryProvider = Provider<PublicityRepository>(
  (ref) => PublicityRepositoryImpl(
    ref.watch(publicityProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(imageServiceProvider),
  ),
);
