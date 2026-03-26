import '../../../../domain/modals/content_home/event.dart';
import '../../../entities/content_home/event_entity.dart';
import 'event_mapper.dart';

class EventListMapper {
  static List<Event> transformToModel(final EventListEntity entities) => entities
      .map(
        (entity) => EventMapper.transformToModel(entity),
      )
      .toList();
}
