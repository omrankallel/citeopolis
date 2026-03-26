import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/state/state.dart';
import '../../../../core/config/prod_config.dart';
import '../../../../core/memory/data_state.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../domain/modals/config_app.dart';
import '../../domain/repositories/preloader_domain_module.dart';
import '../../domain/usecases/preloader_use_case.dart';

final preloaderListProvider = Provider.autoDispose<State<st.Either<String, ConfigApp>>>((ref) {
  final preloaderState = ref.watch(preloaderViewModelStateNotifierProvider);
  return preloaderState.state.when(
    init: () => const State.init(),
    success: (preloader) => State.success(preloader),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final preloaderViewModelStateNotifierProvider = StateNotifierProvider.autoDispose<PreloaderViewModel, DataState<ConfigApp>>(
  (ref) => PreloaderViewModel(
    ref.watch(preloaderUseCaseProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(updatePreloader),
  ),
);

class PreloaderViewModel extends StateNotifier<DataState<ConfigApp>> {
  final PreloaderUseCase _preloaderUseCase;
  final ConnectivityService _connectivityService;
  final bool updatePreloader;

  PreloaderViewModel(
    this._preloaderUseCase,
    this._connectivityService,
    this.updatePreloader,
  ) : super(const DataState<ConfigApp>(state: State.init())) {
    loadPreloaderConfig();
  }

  Future<void> loadPreloaderConfig() async {
    try {
      final String idProject = ProdConfig().projectId;
      final projectId = int.parse(idProject);

      final localResult = await _preloaderUseCase.getConfigProjectFromLocal(projectId);
      final hasCachedData = localResult.isRight();

      if (hasCachedData) {
        if (mounted) {
          state = state.copyWith(
            state: State.success(localResult),
            isFromCache: true,
          );
        }
      } else {
        if (mounted) {
          state = state.copyWith(state: const State.loading());
        }
      }

      final hasConnection = await _connectivityService.hasConnection();

      if (!mounted) return;
      state = state.copyWith(hasConnection: hasConnection);

      if (hasConnection) {
        final serverResult = await _preloaderUseCase.getConfigProjectFromServer(projectId);

        if (!mounted) return;

        serverResult.fold(
          (error) {
            if (!hasCachedData) {
              state = state.copyWith(
                state: State.error(Exception(error)),
                isFromCache: false,
              );
            }
          },
          (config) {
            state = state.copyWith(
              state: State.success(serverResult),
              isFromCache: false,
            );
          },
        );
      } else if (!hasCachedData) {
        state = state.copyWith(
          state: State.error(Exception('Aucune donnée disponible hors ligne')),
          isFromCache: true,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        state = state.copyWith(
          state: State.error(Exception('Erreur fatale: ${e.toString()}')),
          isFromCache: false,
        );
      }
    }
  }
}
