import 'package:dartz/dartz.dart';

import '../../modals/menu/menu.dart';

abstract class MenuUseCase {

  Future<Either<String, List<Menu>>> getMenuProject(int idProject);
  Future<Either<String, List<Menu>>> getMenuProjectFromServer(int idProject);
  Future<Either<String, List<Menu>>> getMenuProjectFromLocal(int idProject);
}
