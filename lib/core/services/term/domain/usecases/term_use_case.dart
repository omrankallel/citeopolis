import 'package:dartz/dartz.dart';

import '../modals/term.dart';

abstract class TermUseCase {
  Future<Either<String, List<Term>>> getTermProject(int idProject);
  Future<Either<String, List<Term>>> getTermProjectFromServer(int idProject);
  Future<Either<String, List<Term>>> getTermProjectFromLocal(int idProject);
}
