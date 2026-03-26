import 'package:dartz/dartz.dart';

import '../../entities/content_home/build_page_entity.dart';

abstract class ContentHomeService {
  Future<Either<String, BuildPageEntity>> getPageHome(int idProject);
}
