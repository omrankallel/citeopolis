
import '../../../../domain/modals/content_home/row.dart';
import '../../../entities/content_home/row_entity.dart';

class RowMapper {
  static Row transformToModel(final RowEntity entity) {
    try {
      return Row(
        title: entity['title'],
        titleColor: entity['title_color'],
        secondaryTitle: entity['secondary_title'],
        radiusBorder: entity['radius_border'],
        edgeBorder: entity['edge_border'],
        borderColor: entity['border_color'],
        colorBackground: entity['color_background'],
        automaticPictogram: entity['automatic_pictogram'],
        pictogram: entity['pictogram'].toString() == 'true' || entity['pictogram'].toString() == '1' || entity['pictogram'].toString() == 'false' || entity['pictogram'].toString() == '0' ? null : entity['pictogram']['url'],
        sizeQuickAccess: entity['size_quick_access'],
        typeLink: entity['type_link'],
        urlLink: entity['url_link'],
        tile: entity['tile'],
      );
    } catch (e) {
      return Row();
    }
  }
}
