import '../../../domain/modals/feed.dart';
import '../../entities/feed_entity.dart';

class FeedMapper {
  static Feed transformToModel(final FeedEntity entity) {
    try {
      return Feed(
        id: entity['ID'],
        title: entity['title'],
        balise: entity['balise'],
        type: entity['type'] == null ? [] : List<String>.from(entity['type'].map((x) => x)),
        status: false,
      );
    } catch (e) {
      return Feed();
    }
  }
}
