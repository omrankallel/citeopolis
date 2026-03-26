import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/network/connectivity_provider.dart';
import '../../../../../../core/services/image_app/image_service_impl.dart';
import '../../../../../core/services/image_app/image_service.dart';
import '../../../domain/repositories/content_home/content_home_repository.dart';
import '../../service/content_home/content_home_service.dart';
import '../../service/content_home/content_home_service_impl.dart';
import '../../service/content_home/flux_rss_service.dart';
import '../../service/content_home/flux_rss_service_impl.dart';
import '../content_home/content_home_repository_impl.dart';

final contentHomeProvider = Provider<ContentHomeService>((_) => ContentHomeServiceImpl());
final fluxRSSProvider = Provider<FluxRSSService>((_) => FluxRSSServiceImpl());
final imageServiceProvider = Provider<ImageService>((_) => ImageServiceImpl());

final contentHomeRepositoryProvider = Provider<ContentHomeRepository>(
  (ref) => ContentHomeRepositoryImpl(
    ref.watch(contentHomeProvider),
    ref.watch(fluxRSSProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(imageServiceProvider),
  ),
);
