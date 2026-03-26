import 'package:dartz/dartz.dart';

import '../modals/config_app.dart';

abstract class PreloaderRepository {
  Future<Either<String, ConfigApp>> getConfigProject(int idProject);

  Future<Either<String, ConfigApp>> getConfigProjectFromServer(int idProject);

  Future<Either<String, ConfigApp>> getConfigProjectFromLocal(int idProject);
}
