import '../entities/image_app_entity.dart';
import '../modals/image_app.dart';
import 'image_app_mapper.dart';

class ImageAppListMapper {
  static List<ImageApp> transformToModel(final ImageAppListEntity entities) => entities
      .map(
        (entity) => ImageAppMapper.transformToModel(entity),
      )
      .toList();
}
