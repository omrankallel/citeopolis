import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/state/state.dart';
import '../../../../../core/config/config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../domain/modals/content_home/build_page.dart';
import '../../../domain/repositories/content_home/content_home_domain_module.dart';
import '../../../domain/usecases/content_home/content_home_use_case.dart';

final buildPageListProvider = Provider<State<st.Either<String, BuildPage>>>((ref) {
  final buildPageAppState = ref.watch(buildPageViewModelStateNotifierProvider);
  return buildPageAppState.state.when(
    init: () => const State.init(),
    success: (buildPage) => State.success(buildPage),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final buildPageViewModelStateNotifierProvider = StateNotifierProvider<BuildPageViewModel, DataState<BuildPage>>(
  (ref) => BuildPageViewModel(
    ref.watch(contentHomeUseCaseProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(updateContentHome),
  ),
);

class BuildPageViewModel extends StateNotifier<DataState<BuildPage>> {
  final ContentHomeUseCase _contentHomeUseCase;
  final ConnectivityService _connectivityService;
  final bool updateContentHome;

  BuildPageViewModel(this._contentHomeUseCase, this._connectivityService, this.updateContentHome) : super(const DataState<BuildPage>(state: State.init())) {
    getPageHomeFromLocal();
  }

  Future<void> getPageHomeFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final buildPage = await _contentHomeUseCase.getPageHomeFromLocal(int.parse(idProject));

      if (mounted) {
        buildPage.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(buildPage),
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
        await getPageHomeFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final buildPage = await _contentHomeUseCase.getPageHomeFromServer(int.parse(idProject));

      if (mounted) {
        buildPage.fold(
          (error) {
            getPageHomeFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(buildPage),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getPageHomeFromLocal();
    }
  }

  Future<void> getPageHome() async {
    await getPageHomeFromLocal();
  }
}
