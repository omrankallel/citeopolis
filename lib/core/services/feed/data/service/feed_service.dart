import 'package:dartz/dartz.dart';

import '../entities/feed_entity.dart';

abstract class FeedService {
  Future<Either<String, FeedListEntity>> getFeedProject(int idProject);
}
