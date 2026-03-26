import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/connectivity_provider.dart';
import '../../../domain/repositories/menu/menu_repository.dart';
import '../../service/menu/menu_service.dart';
import '../../service/menu/menu_service_impl.dart';
import 'menu_repository_impl.dart';

final menuProvider = Provider<MenuService>((_) => MenuServiceImpl());

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepositoryImpl(
    ref.watch(menuProvider),
    ref.watch(connectivityServiceProvider),
  ),
);
