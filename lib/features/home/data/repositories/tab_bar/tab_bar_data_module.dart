import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/network/connectivity_provider.dart';
import '../../../../../../core/services/image_app/image_service.dart';
import '../../../../../../core/services/image_app/image_service_impl.dart';
import '../../../domain/repositories/tab_bar/tab_bar_repository.dart';
import '../../service/tab_bar/tab_bar_service.dart';
import '../../service/tab_bar/tab_bar_service_impl.dart';
import 'tab_bar_repository_impl.dart';

final tabBarProvider = Provider<TabBarService>((_) => TabBarServiceImpl());
final imageServiceProvider = Provider<ImageService>((_) => ImageServiceImpl());

final tabBarRepositoryProvider = Provider<TabBarRepository>(
  (ref) => TabBarRepositoryImpl(
    ref.watch(tabBarProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(imageServiceProvider),
  ),
);
