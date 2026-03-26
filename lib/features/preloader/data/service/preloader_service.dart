import 'package:dartz/dartz.dart';

import '../entities/config_app_entity.dart';

abstract class PreloaderService {
  Future<Either<String, ConfigAppEntity>> getConfigProject(int idProject);
}
