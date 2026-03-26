import '../../../domain/modals/type_tile.dart';
import '../../entities/type_entity.dart';

class TypeMapper {
  static TypeTile transformToModel(final TypeEntity entity) => TypeTile(
        slug: entity['slug'],
        name: entity['name'],
      );
}
