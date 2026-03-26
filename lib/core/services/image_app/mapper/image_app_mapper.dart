import '../entities/image_app_entity.dart';
import '../modals/image_app.dart';

class ImageAppMapper {
  static ImageApp transformToModel(final ImageAppEntity entity) => ImageApp(
        id: entity['ID'],
        filename: entity['filename'],
        url: entity['url'],
        width: entity['width'] == null ? 0.0 : entity['width'] * 1.0,
        height: entity['height'] == null ? 0.0 : entity['height'] * 1.0,
      );
}
