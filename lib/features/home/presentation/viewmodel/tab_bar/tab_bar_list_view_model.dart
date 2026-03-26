import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/state/state.dart';
import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../domain/modals/tab_bar/tab_bar.dart';
import '../../../domain/repositories/tab_bar/tab_bar_domain_module.dart';
import '../../../domain/usecases/tab_bar/tab_bar_use_case.dart';

final tabBarListProvider = Provider<State<st.Either<String, List<TabBar>>>>((ref) {
  final tabBarAppState = ref.watch(tabBarViewModelStateNotifierProvider);
  return tabBarAppState.state.when(
    init: () => const State.init(),
    success: (tabBar) => State.success(tabBar),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final tabBarViewModelStateNotifierProvider = StateNotifierProvider<TabBarViewModel, DataState<List<TabBar>>>(
  (ref) => TabBarViewModel(
    ref.watch(tabBarUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class TabBarViewModel extends StateNotifier<DataState<List<TabBar>>> {
  final TabBarUseCase _tabBarUseCase;
  final ConnectivityService _connectivityService;

  TabBarViewModel(this._tabBarUseCase, this._connectivityService) : super(const DataState<List<TabBar>>(state: State.init())) {
    getTabBarProjectFromLocal();
  }

  Future<void> getTabBarProjectFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final tabBar = await _tabBarUseCase.getTabBarProjectFromLocal(int.parse(idProject));

      if (mounted) {
        tabBar.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(tabBar),
              isFromCache: true,
            );
          },
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(
        state: State.error(e),
        isFromCache: true,
      );
    }
  }

  Future<void> refreshFromServer() async {
    try {
      final hasConnection = await _connectivityService.hasConnection();

      if (!hasConnection) {
        await getTabBarProjectFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final tabBar = await _tabBarUseCase.getTabBarProjectFromServer(int.parse(idProject));

      if (mounted) {
        tabBar.fold(
          (error) {
            getTabBarProjectFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(tabBar),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getTabBarProjectFromLocal();
    }
  }

  Future<void> getTabBarProject() async {
    await getTabBarProjectFromLocal();
  }
}
