import '../../../domain/modals/configuration.dart';
import '../../entities/configuration_entity.dart';
import 'configuration_mapper.dart';

class ConfigurationListMapper {
  static List<Configuration> transformToModel(final ConfigurationListEntity entities) => entities
      .map(
        (entity) => ConfigurationMapper.transformToModel(entity),
      )
      .toList();
}
