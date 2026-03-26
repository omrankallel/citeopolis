import '../../../../../../core/utils/helpers.dart';
import '../../../../../core/services/image_app/mapper/image_app_list_mapper.dart';
import '../../../../../core/services/image_app/mapper/image_app_mapper.dart';
import '../../../domain/modals/configuration.dart';
import '../../entities/configuration_entity.dart';

class ConfigurationMapper {
  static Configuration transformToModel(final ConfigurationEntity entity) => Configuration(
        positionTitle: entity['position_title'],
        titleApp: entity['title_app'],
        backgroundApp: Helpers.isNullEmptyOrFalse(entity['background_app']) || entity['background_app'] == true || entity['background_app'] == false ? null : ImageAppMapper.transformToModel(entity['background_app']),
        logoApp: Helpers.isNullEmptyOrFalse(entity['logo_app']) || entity['logo_app'] == true || entity['logo_app'] == false ? null : ImageAppMapper.transformToModel(entity['logo_app']),
        leadApp: entity['lead_app'],
        positionLead: entity['position_lead'],
        partnerRepeater: Helpers.isNullEmptyOrFalse(entity['partner_repeater']) ? [] : ImageAppListMapper.transformToModel(entity['partner_repeater']),
        mailBug: entity['mail_bug'],
        mailContactCommunity: entity['mail_contact_community'],
        urlLegalPage: entity['url_legal_page'],
        urlProtectionPage: entity['url_protection_page'],
        urlFacebook: entity['url_facebook'],
        urlTwitter: entity['url_twitter'],
        urlLinkedin: entity['url_linkedin'],
        urlYoutube: entity['url_youtube'],
        urlInstagram: entity['url_instagram'],
        adress: entity['adress'],
        zipCode: entity['zip_code'],
        city: entity['city'],
        website: entity['website'],
        phone: entity['phone'],
      );
}
