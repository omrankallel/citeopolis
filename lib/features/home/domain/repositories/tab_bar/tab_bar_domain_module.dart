import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/tab_bar/tab_bar_data_module.dart';
import '../../usecases/tab_bar/tab_bar_use_case.dart';
import '../../usecases/tab_bar/tab_bar_use_case_impl.dart';

final tabBarUseCaseProvider = Provider<TabBarUseCase>(
  (ref) => TabBarUseCaseImpl(ref.watch(tabBarRepositoryProvider)),
);

final updateTabBar = StateProvider<bool>((ref) => false);
