import '../../../../domain/modals/content_home/carrousel.dart';
import '../../../entities/content_home/carrousel_entity.dart';
import 'carrousel_mapper.dart';

class CarrouselListMapper {
  static List<Carrousel> transformToModel(final CarrouselListEntity entities) => entities
      .map(
        (entity) => CarrouselMapper.transformToModel(entity),
      )
      .toList();
}
