import '../../../../../../core/core.dart';
import '../../../../domain/modals/content_home/build_page.dart';
import '../../../entities/content_home/build_page_entity.dart';
import '../section/section_list_mapper.dart';


class BuildPageMapper {
  static BuildPage transformToModel(final BuildPageEntity entity) {
    try {
      return BuildPage(
        sections: Helpers.isNullEmptyOrFalse(entity['sections']) ? [] : SectionListMapper.transformToModel(entity['sections']),
      );
    } catch (e) {
      return BuildPage();
    }
  }
}
