import 'package:dartz/dartz.dart';

import '../modals/term.dart';
import '../repositories/term_repository.dart';
import 'term_use_case.dart';

class TermUseCaseImpl implements TermUseCase {
  final TermRepository _repository;

  const TermUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<Term>>> getTermProject(int idProject) => _repository.getTermProject(idProject);

  @override
  Future<Either<String, List<Term>>> getTermProjectFromServer(int idProject) => _repository.getTermProjectFromServer(idProject);

  @override
  Future<Either<String, List<Term>>> getTermProjectFromLocal(int idProject) => _repository.getTermProjectFromLocal(idProject);
}
