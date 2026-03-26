import '../../../../domain/modals/content_home/flux.dart';
import '../../../entities/content_home/flux_entity.dart';
import 'flux_mapper.dart';

class FluxListMapper {
  static List<Flux> transformToModel(final FluxListEntity entities) => entities
      .map(
        (entity) => FluxMapper.transformToModel(entity),
      )
      .toList();
}
