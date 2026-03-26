import '../../../../../../core/utils/helpers.dart';
import '../../../domain/modals/config_app.dart';
import '../../entities/config_app_entity.dart';
import '../configuration/configuration_mapper.dart';

class ConfigAppMapper {
  static ConfigApp transformToModel(final ConfigAppEntity entity) => ConfigApp(
        id: entity['ID'],
        urlApp: entity['url_app'],
        configuration: Helpers.isNullEmptyOrFalse(entity['configuration']) ? null : ConfigurationMapper.transformToModel(entity['configuration']),
      );
}
