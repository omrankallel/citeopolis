import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/state/state.dart';
import '../../domain/modals/tile.dart';
import '../../domain/repositories/tile_domain_module.dart';
import '../../domain/usecases/tile_use_case.dart';

final tileListProvider = Provider<State<st.Either<String, List<Tile>>>>((ref) {
  final tileAppState = ref.watch(tileViewModelStateNotifierProvider);
  return tileAppState.state.when(
    init: () => const State.init(),
    success: (tile) => State.success(tile),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final tileViewModelStateNotifierProvider = StateNotifierProvider<TileViewModel, DataState<List<Tile>>>(
  (ref) => TileViewModel(
    ref.watch(tileUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class TileViewModel extends StateNotifier<DataState<List<Tile>>> {
  final TileUseCase _tileUseCase;
  final ConnectivityService _connectivityService;

  TileViewModel(this._tileUseCase, this._connectivityService) : super(const DataState<List<Tile>>(state: State.init())) {
    getTileProjectFromLocal();
  }

  Future<void> getTileProjectFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final tile = await _tileUseCase.getTileProjectFromLocal(int.parse(idProject));

      if (mounted) {
        tile.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(tile),
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
        await getTileProjectFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final tile = await _tileUseCase.getTileProjectFromServer(int.parse(idProject));

      if (mounted) {
        tile.fold(
          (error) {
            getTileProjectFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(tile),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getTileProjectFromLocal();
    }
  }

  Future<void> getTileProject() async {
    await getTileProjectFromLocal();
  }
}
