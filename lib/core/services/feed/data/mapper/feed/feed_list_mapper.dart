import '../../../domain/modals/feed.dart';
import '../../entities/feed_entity.dart';
import 'feed_mapper.dart';

class FeedListMapper {
  static List<Feed> transformToModel(final FeedListEntity entities) => entities
      .map(
        (entity) => FeedMapper.transformToModel(entity),
      )
      .toList();
}
