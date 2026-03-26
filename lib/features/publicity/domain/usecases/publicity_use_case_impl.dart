import 'package:dartz/dartz.dart';

import '../modals/publicity.dart';
import '../repositories/publicity_repository.dart';
import 'publicity_use_case.dart';

class PublicityUseCaseImpl implements PublicityUseCase {
  final PublicityRepository _repository;

  const PublicityUseCaseImpl(this._repository);

  @override
  Future<Either<String, Publicity>> getPublicity(int idProject) => _repository.getPublicity(idProject);


  @override
  Future<Either<String, Publicity>> getPublicityFromLocal(int idProject) => _repository.getPublicityFromLocal(idProject);

  @override
  Future<Either<String, Publicity>> getPublicityFromServer(int idProject) => _repository.getPublicityFromServer(idProject);
}
