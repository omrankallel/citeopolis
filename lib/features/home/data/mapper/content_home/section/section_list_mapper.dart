import '../../../../domain/modals/content_home/section.dart';
import '../../../entities/content_home/section_entity.dart';
import 'section_mapper.dart';

class SectionListMapper {
  static List<Section> transformToModel(final SectionListEntity entities) => entities
      .map(
        (entity) => SectionMapper.transformToModel(entity),
      )
      .toList();
}
