import '../../../domain/modals/config_app.dart';
import '../../entities/config_app_entity.dart';
import 'config_app_mapper.dart';

class ConfigAppListMapper {
  static List<ConfigApp> transformToModel(final ConfigAppListEntity entities) => entities
      .map(
        (entity) => ConfigAppMapper.transformToModel(entity),
      )
      .toList();
}
