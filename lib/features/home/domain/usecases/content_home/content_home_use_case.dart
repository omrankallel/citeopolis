import 'package:dartz/dartz.dart';

import '../../modals/content_home/build_page.dart';


abstract class ContentHomeUseCase {
  Future<Either<String, BuildPage>> getPageHome(int idProject);
  Future<Either<String, BuildPage>> getPageHomeFromServer(int idProject);
  Future<Either<String, BuildPage>> getPageHomeFromLocal(int idProject);
}
