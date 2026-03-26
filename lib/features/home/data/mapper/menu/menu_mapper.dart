
import '../../../domain/modals/menu/menu.dart';
import '../../entities/menu/menu_entity.dart';

class MenuMapper {
  static Menu transformToModel(final MenuEntity entity) => Menu(
        id: entity['ID'],
        title: entity['title'],
        typeLinkMenu: entity['type_link_menu'],
        tile: entity['tile'],
        urlLink: entity['url_link'],
        publicMenu: entity['public_menu'],
      );
}
