import 'package:dartz/dartz.dart';

import '../../modals/thematic/thematic.dart';

abstract class ThematicUseCase {
  Future<Either<String, List<Thematic>>> getThematic(int idProject);

  Future<Either<String, List<Thematic>>> getThematicFromServer(int idProject);

  Future<Either<String, List<Thematic>>> getThematicFromLocal(int idProject);
}
