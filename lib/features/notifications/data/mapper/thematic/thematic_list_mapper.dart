import '../../../domain/modals/thematic/thematic.dart';
import '../../entities/thematic/thematic_entity.dart';
import 'thematic_mapper.dart';

class ThematicListMapper {
  static List<Thematic> transformToModel(final ThematicListEntity entities) => entities
      .map(
        (entity) => ThematicMapper.transformToModel(entity),
      )
      .toList();
}
