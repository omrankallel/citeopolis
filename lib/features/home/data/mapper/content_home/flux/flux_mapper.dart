
import '../../../../domain/modals/content_home/flux.dart';
import '../../../entities/content_home/flux_entity.dart';

class FluxMapper {
  static Flux transformToModel(final FluxEntity entity) {
    try {
      return Flux(
        numberElement: entity['number_element'],
        fluxLink: entity['flux_link'],
      );
    } catch (e) {
      return Flux();
    }
  }
}
