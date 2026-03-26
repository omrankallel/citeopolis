import '../../../../../../core/core.dart';
import '../../../domain/modals/tile.dart';
import '../../../domain/modals/type_tile.dart';
import '../../entities/tile_entity.dart';
import '../type/type_mapper.dart';

class TileMapper {
  static Tile transformToModel(final TileEntity entity) {
    try {
      return Tile(
        id: entity['id'],
        title: entity['Title'],
        projectId: entity['project_id'],
        publishTile: entity['publish_tile'],
        type: Helpers.isNullEmptyOrFalse(entity['type']) ? TypeTile() : TypeMapper.transformToModel(entity['type']),
      );
    } catch (e) {
      return Tile();
    }
  }
}
