import '../../../../domain/modals/content_home/row.dart';
import '../../../entities/content_home/row_entity.dart';
import 'row_mapper.dart';

class RowListMapper {
  static List<Row> transformToModel(final RowListEntity entities) => entities
      .map(
        (entity) => RowMapper.transformToModel(entity),
      )
      .toList();
}
