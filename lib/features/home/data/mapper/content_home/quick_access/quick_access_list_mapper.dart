import '../../../../domain/modals/content_home/quick_access.dart';
import '../../../entities/content_home/quick_access_entity.dart';
import 'quick_access_mapper.dart';

class QuickAccessListMapper {
  static List<QuickAccess> transformToModel(final QuickAccessListEntity entities) => entities
      .map(
        (entity) => QuickAccessMapper.transformToModel(entity),
      )
      .toList();
}
