import 'package:dartz/dartz.dart';

import '../modals/tile.dart';
import '../repositories/tile_repository.dart';
import 'tile_use_case.dart';

class TileUseCaseImpl implements TileUseCase {
  final TileRepository _repository;

  const TileUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<Tile>>> getTileProject(int idProject) => _repository.getTileProject(idProject);

  @override
  Future<Either<String, List<Tile>>> getTileProjectFromServer(int idProject) => _repository.getTileProjectFromServer(idProject);

  @override
  Future<Either<String, List<Tile>>> getTileProjectFromLocal(int idProject) => _repository.getTileProjectFromLocal(idProject);
}
