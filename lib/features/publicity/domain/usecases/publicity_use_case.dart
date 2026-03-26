import 'package:dartz/dartz.dart';

import '../modals/publicity.dart';

abstract class PublicityUseCase {
  Future<Either<String, Publicity>> getPublicity(int idProject);
  Future<Either<String, Publicity>> getPublicityFromServer(int idProject);
  Future<Either<String, Publicity>> getPublicityFromLocal(int idProject);
}
