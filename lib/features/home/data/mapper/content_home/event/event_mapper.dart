import '../../../../../../../core/utils/helpers.dart';
import '../../../../domain/modals/content_home/event.dart';
import '../../../../domain/modals/content_home/flux.dart';
import '../../../entities/content_home/event_entity.dart';
import '../flux/flux_mapper.dart';
import '../repeater/repeater_list_mapper.dart';

class EventMapper {
  static Event transformToModel(final EventEntity entity) {
    try {
      return Event(
        titleEvent: entity['title_event'],
        typeLinkEvent: entity['type_link_event'],
        tile: entity['tile'],
        urlLink: entity['url_link'],
        displayMode: entity['display_mode'],
        flux: Helpers.isNullEmptyOrFalse(entity['flux']) ? Flux() : FluxMapper.transformToModel(entity['flux']),
        eventRepeater: Helpers.isNullEmptyOrFalse(entity['event_repeater']) ? [] : RepeaterListMapper.transformToModel(entity['event_repeater']),
      );
    } catch (e) {
      return Event();
    }
  }
}
