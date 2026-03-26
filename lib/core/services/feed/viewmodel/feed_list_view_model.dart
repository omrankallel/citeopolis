import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/state/state.dart';
import '../domain/modals/feed.dart';
import '../domain/repositories/feed_domain_module.dart';
import '../domain/usecases/feed_use_case.dart';

final feedListProvider = Provider<State<st.Either<String, List<Feed>>>>((ref) {
  final feedAppState = ref.watch(feedViewModelStateNotifierProvider);
  return feedAppState.state.when(
    init: () => const State.init(),
    success: (feed) => State.success(feed),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final feedViewModelStateNotifierProvider = StateNotifierProvider<FeedViewModel, DataState<List<Feed>>>(
  (ref) => FeedViewModel(
    ref.watch(feedUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class FeedViewModel extends StateNotifier<DataState<List<Feed>>> {
  final FeedUseCase _feedUseCase;
  final ConnectivityService _connectivityService;

  FeedViewModel(this._feedUseCase, this._connectivityService) : super(const DataState<List<Feed>>(state: State.init())) {
    getFeedProjectFromLocal();
  }

  Future<void> getFeedProjectFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final feed = await _feedUseCase.getFeedProjectFromLocal(int.parse(idProject));

      if (mounted) {
        feed.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(feed),
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
        await getFeedProjectFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final feed = await _feedUseCase.getFeedProjectFromServer(int.parse(idProject));

      if (mounted) {
        feed.fold(
          (error) {
            getFeedProjectFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(feed),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getFeedProjectFromLocal();
    }
  }

  Future<void> getFeedProject() async {
    await getFeedProjectFromLocal();
  }
}
