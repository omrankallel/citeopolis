import '../../../domain/modals/menu/menu.dart';
import '../../entities/menu/menu_entity.dart';
import 'menu_mapper.dart';

class MenuListMapper {
  static List<Menu> transformToModel(final MenuListEntity entities) => entities
      .map(
        (entity) => MenuMapper.transformToModel(entity),
      )
      .toList();
}
