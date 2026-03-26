import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/state/state.dart';
import '../domain/modals/term.dart';
import '../domain/repositories/term_domain_module.dart';
import '../domain/usecases/term_use_case.dart';

final termListProvider = Provider<State<st.Either<String, List<Term>>>>((ref) {
  final termAppState = ref.watch(termViewModelStateNotifierProvider);
  return termAppState.state.when(
    init: () => const State.init(),
    success: (term) => State.success(term),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final termViewModelStateNotifierProvider = StateNotifierProvider<TermViewModel, DataState<List<Term>>>(
  (ref) => TermViewModel(
    ref.watch(termUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class TermViewModel extends StateNotifier<DataState<List<Term>>> {
  final TermUseCase _termUseCase;
  final ConnectivityService _connectivityService;

  TermViewModel(this._termUseCase, this._connectivityService) : super(const DataState<List<Term>>(state: State.init())) {
    getTermProjectFromLocal();
  }

  Future<void> getTermProjectFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final term = await _termUseCase.getTermProjectFromLocal(int.parse(idProject));

      if (mounted) {
        term.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(term),
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
        await getTermProjectFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final term = await _termUseCase.getTermProjectFromServer(int.parse(idProject));

      if (mounted) {
        term.fold(
          (error) {
            getTermProjectFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(term),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getTermProjectFromLocal();
    }
  }

  Future<void> getTermProject() async {
    await getTermProjectFromLocal();
  }
}
