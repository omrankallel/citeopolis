import 'package:dartz/dartz.dart';

import '../../modals/tab_bar/tab_bar.dart';

abstract class TabBarUseCase {
  Future<Either<String, List<TabBar>>> getTabBarProject(int idProject);

  Future<Either<String, List<TabBar>>> getTabBarProjectFromLocal(int idProject);

  Future<Either<String, List<TabBar>>> getTabBarProjectFromServer(int idProject);
}
