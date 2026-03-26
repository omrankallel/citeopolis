import '../../../domain/modals/type_tile.dart';
import '../../entities/type_entity.dart';
import 'type_mapper.dart';

class TypeListMapper {
  static List<TypeTile> transformToModel(final TypeListEntity entities) => entities
      .map(
        (entity) => TypeMapper.transformToModel(entity),
      )
      .toList();
}
