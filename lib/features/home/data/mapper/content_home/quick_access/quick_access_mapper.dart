import '../../../../../../../core/utils/helpers.dart';
import '../../../../domain/modals/content_home/quick_access.dart';
import '../../../entities/content_home/quick_access_entity.dart';
import '../row/row_list_mapper.dart';

class QuickAccessMapper {
  static QuickAccess transformToModel(final QuickAccessEntity entity) {
    try {
      return QuickAccess(
        rows: Helpers.isNullEmptyOrFalse(entity['rows']) ? [] : RowListMapper.transformToModel(entity['rows']),
      );
    } catch (e) {
      return QuickAccess();
    }
  }
}
