import 'package:dartz/dartz.dart';

import '../../entities/menu/menu_entity.dart';


abstract class MenuService {
  Future<Either<String, MenuListEntity>> getMenuProject(int idProject);

}
