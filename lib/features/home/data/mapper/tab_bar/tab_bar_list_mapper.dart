import '../../../domain/modals/tab_bar/tab_bar.dart';
import '../../entities/tab_bar/tab_bar_entity.dart';
import 'tab_bar_mapper.dart';

class TabBarListMapper {
  static List<TabBar> transformToModel(final TabBarListEntity entities) => entities
      .map(
        (entity) => TabBarMapper.transformToModel(entity),
      )
      .toList();
}
