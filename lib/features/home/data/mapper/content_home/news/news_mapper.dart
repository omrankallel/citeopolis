import '../../../../../../../core/utils/helpers.dart';
import '../../../../domain/modals/content_home/flux.dart';
import '../../../../domain/modals/content_home/news.dart';
import '../../../entities/content_home/news_entity.dart';
import '../flux/flux_mapper.dart';
import '../repeater/repeater_list_mapper.dart';

class NewsMapper {
  static News transformToModel(final NewsEntity entity) {
    try {
      return News(
        titleNews: entity['title_news'],
        typeLinkNews: entity['type_link_news'],
        tile: entity['tile'],
        urlLink: entity['url_link'],
        displayMode: entity['display_mode'],
        flux: Helpers.isNullEmptyOrFalse(entity['flux']) ? Flux() : FluxMapper.transformToModel(entity['flux']),
        newsRepeater: Helpers.isNullEmptyOrFalse(entity['news_repeater']) ? [] : RepeaterListMapper.transformToModel(entity['news_repeater']),
      );
    } catch (e) {
      return News();
    }
  }
}
