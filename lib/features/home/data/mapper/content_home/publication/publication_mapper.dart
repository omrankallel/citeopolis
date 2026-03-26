import '../../../../../../../core/utils/helpers.dart';
import '../../../../domain/modals/content_home/flux.dart';
import '../../../../domain/modals/content_home/publication.dart';
import '../../../entities/content_home/publication_entity.dart';
import '../flux/flux_mapper.dart';
import '../repeater/repeater_list_mapper.dart';

class PublicationMapper {
  static Publication transformToModel(final PublicationEntity entity) {
    try {
      return Publication(
        titlePublication: entity['title_publcation'],
        typeLinkPublication: entity['type_link_publication'],
        tile: entity['tile'],
        urlLink: entity['url_link'],
        displayMode: entity['display_mode'],
        flux: Helpers.isNullEmptyOrFalse(entity['flux']) ? Flux() : FluxMapper.transformToModel(entity['flux']),
        publicationRepeater: Helpers.isNullEmptyOrFalse(entity['publcation_repeater']) ? [] : RepeaterListMapper.transformToModel(entity['publcation_repeater']),
      );
    } catch (e) {
      return Publication();
    }
  }
}
