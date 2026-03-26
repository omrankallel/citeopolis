import '../../../../domain/modals/content_home/repeater.dart';
import '../../../entities/content_home/repeater_entity.dart';
import 'repeater_mapper.dart';

class RepeaterListMapper {
  static List<Repeater> transformToModel(final RepeaterListEntity entities) => entities
      .map(
        (entity) => RepeaterMapper.transformToModel(entity),
      )
      .toList();
}
