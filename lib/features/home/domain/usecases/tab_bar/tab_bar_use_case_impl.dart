import 'package:dartz/dartz.dart';

import '../../modals/tab_bar/tab_bar.dart';
import '../../repositories/tab_bar/tab_bar_repository.dart';
import 'tab_bar_use_case.dart';

class TabBarUseCaseImpl implements TabBarUseCase {
  final TabBarRepository _repository;

  const TabBarUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<TabBar>>> getTabBarProject(int idProject) => _repository.getTabBarProject(idProject);

  @override
  Future<Either<String, List<TabBar>>> getTabBarProjectFromServer(int idProject) => _repository.getTabBarProjectFromServer(idProject);

  @override
  Future<Either<String, List<TabBar>>> getTabBarProjectFromLocal(int idProject) => _repository.getTabBarProjectFromLocal(idProject);
}
