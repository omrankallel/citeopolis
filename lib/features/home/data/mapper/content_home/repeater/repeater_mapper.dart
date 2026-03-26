
import '../../../../domain/modals/content_home/repeater.dart';
import '../../../entities/content_home/repeater_entity.dart';

class RepeaterMapper {
  static Repeater transformToModel(final RepeaterEntity entity) {
    try {
      return Repeater(
        repTitle: entity['rep_title'],
        repThematic: entity['rep_thematic'],
        repPictoImg: entity['rep_picto_img'],
        repStartDate: entity['rep_start_date'],
        repEndDate: entity['rep_end_date'],
        repTypeLink: entity['rep_type_link'],
        repTile: entity['rep_tile'],
        repUrl: entity['rep_url'],
      );
    } catch (e) {
      return Repeater();
    }
  }
}
