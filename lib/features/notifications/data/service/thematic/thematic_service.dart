import 'package:dartz/dartz.dart';

import '../../entities/thematic/thematic_entity.dart';

abstract class ThematicService {
  Future<Either<String, ThematicListEntity>> getThematic(int idProject);

}
