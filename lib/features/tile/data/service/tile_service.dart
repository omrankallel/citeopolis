import 'package:dartz/dartz.dart';

import '../entities/tile_entity.dart';

abstract class TileService {
  Future<Either<String, TileListEntity>> getTileProject(int idProject);
}
