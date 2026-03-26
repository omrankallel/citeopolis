import '../../../../../../core/utils/helpers.dart';
import '../../../../domain/modals/content_home/carrousel.dart';
import '../../../../domain/modals/content_home/event.dart';
import '../../../../domain/modals/content_home/news.dart';
import '../../../../domain/modals/content_home/publication.dart';
import '../../../../domain/modals/content_home/quick_access.dart';
import '../../../../domain/modals/content_home/section.dart';
import '../../../entities/content_home/section_entity.dart';
import '../../content_home/carrousel/carrousel_mapper.dart';
import '../../content_home/event/event_mapper.dart';
import '../../content_home/news/news_mapper.dart';
import '../../content_home/publication/publication_mapper.dart';
import '../../content_home/quick_access/quick_access_mapper.dart';

class SectionMapper {
  static Section transformToModel(final SectionEntity entity) {
    try {
      final String type = entity['type'] ?? '';
      final data = entity['data'];
      Carrousel carrousel = Carrousel();
      QuickAccess quickAccess = QuickAccess();
      News news = News();
      Event event = Event();
      Publication publication = Publication();

      switch (type) {
        case 'carousel':
          carrousel = Helpers.isNullEmptyOrFalse(data) ? Carrousel() : CarrouselMapper.transformToModel(data);
          break;

        case 'quick_access':
          quickAccess = Helpers.isNullEmptyOrFalse(data) ? QuickAccess() : QuickAccessMapper.transformToModel(data);
          break;

        case 'news':
          news = Helpers.isNullEmptyOrFalse(data) ? News() : NewsMapper.transformToModel(data);
          break;

        case 'event':
          event = Helpers.isNullEmptyOrFalse(data) ? Event() : EventMapper.transformToModel(data);
          break;

        case 'publication':
          publication = Helpers.isNullEmptyOrFalse(data) ? Publication() : PublicationMapper.transformToModel(data);
          break;
      }

      return Section(
        type: type,
        order: entity['order'],
        hidden: entity['hidden'],
        carrousel: carrousel,
        quickAccess: quickAccess,
        news: news,
        event: event,
        publication: publication,
      );
    } catch (e) {
      return Section();
    }
  }
}
