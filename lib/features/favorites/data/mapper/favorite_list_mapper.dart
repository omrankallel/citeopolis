import '../../domain/modals/favorite.dart';
import '../entities/favorite_entity.dart';
import 'favorite_mapper.dart';

class FavoriteListMapper {
  static List<Favorite> transformToModel(final FavoriteListEntity entities) => entities
      .map(
        (entity) => FavoriteMapper.transformToModel(entity),
      )
      .toList();
}
