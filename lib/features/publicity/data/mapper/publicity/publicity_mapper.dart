import '../../../../../../core/utils/helpers.dart';
import '../../../../../core/services/image_app/mapper/image_app_mapper.dart';
import '../../../domain/modals/publicity.dart';
import '../../entities/publicity_entity.dart';

class PublicityMapper {
  static Publicity transformToModel(final PublicityEntity entity) {
    try {
      return Publicity(
        id: entity['ID'],
        positionTitlePublicity: entity['position_title_publicity'],
        titlePublicity: entity['title_publicity'],
        leadPublicity: entity['lead_publicity'],
        imgPublicity: Helpers.isNullEmptyOrFalse(entity['img_publicity']) || entity['img_publicity'] == true || entity['img_publicity'] == false ? null : ImageAppMapper.transformToModel(entity['img_publicity']),
        showButton: entity['show_button'],
        buttonText: entity['button_text'],
        typeLinkPublicity: entity['type_link_publicity'],
        urlLink: entity['url_link'],
        tile: entity['tile'],
        displayStartDatePublicity: entity['display_start_date_publicity'],
        displayEndDatePublicity: entity['display_end_date_publicity'],
        displayTimeSeconds: entity['display_time_seconds'],
      );
    } catch (e) {
      return Publicity();
    }
  }
}
