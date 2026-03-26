import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/state/state.dart';
import '../../data/repositories/tile_detail_data_module.dart';
import '../../domain/usecases/tile_detail_use_case.dart';

final tileDetailProvider = StateProvider<State<st.Either<String, dynamic>>>((ref) => const State.init());

final tileDetailViewModelStateNotifierProvider = StateNotifierProvider.family<TileDetailViewModel, DataState<dynamic>, TileDetailParams>(
      (ref, params) => TileDetailViewModel(
    ref.watch(tileDetailUseCaseProvider),
    ref.watch(connectivityServiceProvider),
    params,
  ),
);

class TileDetailParams {
  final String tileId;
  final String tileType;

  const TileDetailParams({
    required this.tileId,
    required this.tileType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TileDetailParams &&
              runtimeType == other.runtimeType &&
              tileId == other.tileId &&
              tileType == other.tileType;

  @override
  int get hashCode => tileId.hashCode ^ tileType.hashCode;
}

class TileDetailViewModel extends StateNotifier<DataState<dynamic>> {
  final TileDetailUseCase _tileDetailUseCase;
  final ConnectivityService _connectivityService;
  final TileDetailParams _params;

  TileDetailViewModel(
      this._tileDetailUseCase,
      this._connectivityService,
      this._params,
      ) : super(const DataState<dynamic>(state: State.init())) {
    getTileDetailFromLocal();
  }

  Future<void> getTileDetailFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final tileDetail = await _tileDetailUseCase.getTileDetailFromLocal(_params.tileId, _params.tileType);

      if (mounted) {
        tileDetail.fold(
              (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
              (r) {
            state = state.copyWith(
              state: State.success(st.Right(r)),
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
        await getTileDetailFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final tileDetail = await _tileDetailUseCase.getTileDetailFromServer(_params.tileId, _params.tileType);

      if (mounted) {
        tileDetail.fold(
              (error) {
            getTileDetailFromLocal();
          },
              (r) {
            state = state.copyWith(
              state: State.success(st.Right(r)),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getTileDetailFromLocal();
    }
  }

  Future<void> getTileDetail() async {
    await getTileDetailFromLocal();
  }
}