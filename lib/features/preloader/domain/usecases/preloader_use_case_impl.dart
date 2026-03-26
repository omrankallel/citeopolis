import 'package:dartz/dartz.dart';

import '../modals/config_app.dart';
import '../repositories/preloader_repository.dart';
import 'preloader_use_case.dart';

class PreloaderUseCaseImpl implements PreloaderUseCase {
  final PreloaderRepository _repository;

  const PreloaderUseCaseImpl(this._repository);

  @override
  Future<Either<String, ConfigApp>> getConfigProject(int idProject) => _repository.getConfigProject(idProject);

  @override
  Future<Either<String, ConfigApp>> getConfigProjectFromServer(int idProject) => _repository.getConfigProjectFromServer(idProject);

  @override
  Future<Either<String, ConfigApp>> getConfigProjectFromLocal(int idProject) => _repository.getConfigProjectFromLocal(idProject);
}
