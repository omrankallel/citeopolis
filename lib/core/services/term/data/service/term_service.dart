import 'package:dartz/dartz.dart';

import '../entities/term_entity.dart';

abstract class TermService {
  Future<Either<String, TermListEntity>> getTermProject(int idProject);
}
