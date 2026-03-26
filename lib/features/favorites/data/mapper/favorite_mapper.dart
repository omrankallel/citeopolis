import '../../domain/modals/favorite.dart';
import '../entities/favorite_entity.dart';

class FavoriteMapper {
  static Favorite transformToModel(final FavoriteEntity entity) => Favorite(
        id: entity['id'],
        type: entity['type'],
        title: entity['title'],
        subtitle: entity['subtitle'],
        imageUrl: entity['imageUrl'],
        localImagePath: entity['localImagePath'],
        originalData: Map<String, dynamic>.from(entity['originalData']),
        createdAt: DateTime.parse(entity['createdAt']),
        updatedAt: entity['updatedAt'] != null ? DateTime.parse(entity['updatedAt']) : null,
      );
}
