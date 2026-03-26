import '../../../../domain/modals/content_home/build_page.dart';
import '../../../entities/content_home/build_page_entity.dart';
import 'build_page_mapper.dart';

class BuildPageListMapper {
  static List<BuildPage> transformToModel(final BuildPageListEntity entities) => entities
      .map(
        (entity) => BuildPageMapper.transformToModel(entity),
      )
      .toList();
}
