import '../../../../../../core/services/image_app/mapper/image_app_mapper.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../domain/modals/tab_bar/tab_bar.dart';
import '../../entities/tab_bar/tab_bar_entity.dart';

class TabBarMapper {
  static TabBar transformToModel(final TabBarEntity entity) {
    try {
      return TabBar(
        titleTabBar: entity['title_tab_bar'],
        pictoImg: Helpers.isNullEmptyOrFalse(entity['picto_img']) || entity['picto_img'] == true || entity['picto_img'] == false ? null : ImageAppMapper.transformToModel(entity['picto_img']),
        typeLinkTabBar: entity['type_link_tab_bar'],
        tile: entity['tile'],
        urlLink: entity['url_link'],
        publicTabBar: entity['public_tab_bar'],
        icon: entity['icon'],
      );
    } catch (e) {
      return TabBar();
    }
  }
}
