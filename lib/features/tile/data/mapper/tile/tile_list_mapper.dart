import '../../../domain/modals/tile.dart';
import '../../entities/tile_entity.dart';
import 'tile_mapper.dart';

class TileListMapper {
  static List<Tile> transformToModel(final TileListEntity entities) => entities
      .map(
        (entity) => TileMapper.transformToModel(entity),
      )
      .toList();
}
