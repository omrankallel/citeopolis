import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/state/state.dart';
import '../../../domain/modals/menu/menu.dart';
import '../../../domain/repositories/menu/menu_domain_module.dart';
import '../../../domain/usecases/menu/menu_use_case.dart';

final menuListProvider = Provider<State<st.Either<String, List<Menu>>>>((ref) {
  final menuAppState = ref.watch(menuViewModelStateNotifierProvider);
  return menuAppState.state.when(
    init: () => const State.init(),
    success: (menu) => State.success(menu),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final menuViewModelStateNotifierProvider = StateNotifierProvider<MenuViewModel, DataState<List<Menu>>>(
  (ref) => MenuViewModel(
    ref.watch(menuUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class MenuViewModel extends StateNotifier<DataState<List<Menu>>> {
  final MenuUseCase _menuUseCase;
  final ConnectivityService _connectivityService;

  MenuViewModel(this._menuUseCase, this._connectivityService) : super(const DataState<List<Menu>>(state: State.init())) {
    getMenuProjectFromLocal();
  }

  Future<void> getMenuProjectFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final menu = await _menuUseCase.getMenuProjectFromLocal(int.parse(idProject));

      if (mounted) {
        menu.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(menu),
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
        await getMenuProjectFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final menu = await _menuUseCase.getMenuProjectFromServer(int.parse(idProject));

      if (mounted) {
        menu.fold(
          (error) {
            getMenuProjectFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(menu),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getMenuProjectFromLocal();
    }
  }

  Future<void> getMenuProject() async {
    await getMenuProjectFromLocal();
  }
}
