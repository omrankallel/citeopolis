import 'package:dartz/dartz.dart';

import '../../modals/menu/menu.dart';
import '../../repositories/menu/menu_repository.dart';
import 'menu_use_case.dart';

class MenuUseCaseImpl implements MenuUseCase {
  final MenuRepository _repository;

  const MenuUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<Menu>>> getMenuProject(int idProject) => _repository.getMenuProject(idProject);

  @override
  Future<Either<String, List<Menu>>> getMenuProjectFromServer(int idProject) => _repository.getMenuProjectFromServer(idProject);

  @override
  Future<Either<String, List<Menu>>> getMenuProjectFromLocal(int idProject) => _repository.getMenuProjectFromLocal(idProject);
}
