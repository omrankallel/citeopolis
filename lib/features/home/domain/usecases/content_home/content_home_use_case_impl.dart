import 'package:dartz/dartz.dart';

import '../../modals/content_home/build_page.dart';
import '../../repositories/content_home/content_home_repository.dart';
import 'content_home_use_case.dart';

class ContentHomeUseCaseImpl implements ContentHomeUseCase {
  final ContentHomeRepository _repository;

  const ContentHomeUseCaseImpl(this._repository);

  @override
  Future<Either<String, BuildPage>> getPageHome(int idProject) => _repository.getPageHome(idProject);

  @override
  Future<Either<String, BuildPage>> getPageHomeFromLocal(int idProject) => _repository.getPageHomeFromLocal(idProject);

  @override
  Future<Either<String, BuildPage>> getPageHomeFromServer(int idProject) => _repository.getPageHomeFromServer(idProject);
}
