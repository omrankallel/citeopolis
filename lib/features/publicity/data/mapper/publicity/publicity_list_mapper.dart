import '../../../domain/modals/publicity.dart';
import '../../entities/publicity_entity.dart';
import 'publicity_mapper.dart';

class PublicityListMapper {
  static List<Publicity> transformToModel(final PublicityListEntity entities) => entities
      .map(
        (entity) => PublicityMapper.transformToModel(entity),
      )
      .toList();
}
