import 'package:dartz/dartz.dart';

import '../modals/feed.dart';

abstract class FeedRepository {
  Future<Either<String, List<Feed>>> getFeedProject(int idProject);
  Future<Either<String, List<Feed>>> getFeedProjectFromServer(int idProject);
  Future<Either<String, List<Feed>>> getFeedProjectFromLocal(int idProject);
}
