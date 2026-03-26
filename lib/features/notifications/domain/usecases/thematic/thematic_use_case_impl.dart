import 'package:dartz/dartz.dart';

import '../../modals/thematic/thematic.dart';
import '../../repositories/thematic/thematic_repository.dart';
import 'thematic_use_case.dart';

class ThematicUseCaseImpl implements ThematicUseCase {
  final ThematicRepository _repository;

  const ThematicUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<Thematic>>> getThematic(int idProject) => _repository.getThematic(idProject);

  @override
  Future<Either<String, List<Thematic>>> getThematicFromLocal(int idProject) => _repository.getThematicFromLocal(idProject);

  @override
  Future<Either<String, List<Thematic>>> getThematicFromServer(int idProject) => _repository.getThematicFromServer(idProject);
}
