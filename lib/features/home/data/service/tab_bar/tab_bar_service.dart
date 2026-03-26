import 'package:dartz/dartz.dart';

import '../../entities/tab_bar/tab_bar_entity.dart';

abstract class TabBarService {
  Future<Either<String, TabBarListEntity>> getTabBarProject(int idProject);

 }
