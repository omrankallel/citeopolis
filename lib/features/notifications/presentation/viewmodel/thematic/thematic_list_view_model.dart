import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/state/state.dart';
import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../domain/modals/thematic/thematic.dart';
import '../../../domain/repositories/thematic/thematic_domain_module.dart';
import '../../../domain/usecases/thematic/thematic_use_case.dart';

final thematicListProvider = Provider<State<st.Either<String, List<Thematic>>>>((ref) {
  final thematicAppState = ref.watch(thematicViewModelStateNotifierProvider);
  return thematicAppState.state.when(
    init: () => const State.init(),
    success: (thematic) => State.success(thematic),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final thematicViewModelStateNotifierProvider = StateNotifierProvider<ThematicViewModel, DataState<List<Thematic>>>(
  (ref) => ThematicViewModel(
    ref.watch(thematicUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class ThematicViewModel extends StateNotifier<DataState<List<Thematic>>> {
  final ThematicUseCase _thematicUseCase;
  final ConnectivityService _connectivityService;

  ThematicViewModel(this._thematicUseCase, this._connectivityService) : super(const DataState<List<Thematic>>(state: State.init())) {
    getThematicFromLocal();
  }

  Future<void> getThematicFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final thematic = await _thematicUseCase.getThematicFromLocal(int.parse(idProject));

      if (mounted) {
        thematic.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(thematic),
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
        await getThematicFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final thematic = await _thematicUseCase.getThematicFromServer(int.parse(idProject));

      if (mounted) {
        thematic.fold(
          (error) {
            getThematicFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(thematic),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getThematicFromLocal();
    }
  }

  Future<void> getThematic() async {
    await getThematicFromLocal();
  }
}
