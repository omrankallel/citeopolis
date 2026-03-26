import '../../../../domain/modals/content_home/news.dart';
import '../../../entities/content_home/news_entity.dart';
import 'news_mapper.dart';

class NewsListMapper {
  static List<News> transformToModel(final NewsListEntity entities) => entities
      .map(
        (entity) => NewsMapper.transformToModel(entity),
      )
      .toList();
}
