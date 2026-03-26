import '../../../../../../../core/utils/helpers.dart';
import '../../../../domain/modals/content_home/carrousel.dart';
import '../../../entities/content_home/carrousel_entity.dart';
import '../repeater/repeater_list_mapper.dart';

class CarrouselMapper {
  static Carrousel transformToModel(final CarrouselEntity entity) {
    try {
      return Carrousel(
        carrouselRepeater: Helpers.isNullEmptyOrFalse(entity['carrousel_repeater']) ? [] : RepeaterListMapper.transformToModel(entity['carrousel_repeater']),
      );
    } catch (e) {
      return Carrousel();
    }
  }
}
