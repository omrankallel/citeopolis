import 'package:dartz/dartz.dart';

import '../modals/tile.dart';

abstract class TileRepository {
  Future<Either<String, List<Tile>>> getTileProject(int idProject);
  Future<Either<String, List<Tile>>> getTileProjectFromServer(int idProject);
  Future<Either<String, List<Tile>>> getTileProjectFromLocal(int idProject);
}
