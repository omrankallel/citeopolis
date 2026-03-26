import 'package:dartz/dartz.dart';

import '../entities/publicity_entity.dart';

abstract class PublicityService {
  Future<Either<String, PublicityEntity>> getPublicity(int idProject);

}
