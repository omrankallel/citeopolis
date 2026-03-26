import 'package:dartz/dartz.dart';

import '../modals/feed.dart';
import '../repositories/feed_repository.dart';
import 'feed_use_case.dart';

class FeedUseCaseImpl implements FeedUseCase {
  final FeedRepository _repository;

  const FeedUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<Feed>>> getFeedProject(int idProject) => _repository.getFeedProject(idProject);

  @override
  Future<Either<String, List<Feed>>> getFeedProjectFromServer(int idProject) => _repository.getFeedProjectFromServer(idProject);

  @override
  Future<Either<String, List<Feed>>> getFeedProjectFromLocal(int idProject) => _repository.getFeedProjectFromLocal(idProject);
}
