import 'package:dartz/dartz.dart';

import '../repositories/tile_detail_repository.dart';
import 'tile_detail_use_case.dart';

class TileDetailUseCaseImpl implements TileDetailUseCase {
  final TileDetailRepository _repository;

  const TileDetailUseCaseImpl(this._repository);

  @override
  Future<Either<String, dynamic>> getTileDetail(String tileId, String tileType) =>
      _repository.getTileDetail(tileId, tileType);

  @override
  Future<Either<String, dynamic>> getTileDetailFromServer(String tileId, String tileType) =>
      _repository.getTileDetailFromServer(tileId, tileType);

  @override
  Future<Either<String, dynamic>> getTileDetailFromLocal(String tileId, String tileType) =>
      _repository.getTileDetailFromLocal(tileId, tileType);
}