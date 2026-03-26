import '../../../domain/modals/thematic/thematic.dart';
import '../../entities/thematic/thematic_entity.dart';

class ThematicMapper {
  static Thematic transformToModel(final ThematicEntity entity) {
    try {
      return Thematic(
        termId: entity['term_id'],
        name: entity['name'],
        slug: entity['slug'],
        termGroup: entity['term_group'],
        termTaxonomyId: entity['term_taxonomy_id'],
        taxonomy: entity['taxonomy'],
        description: entity['description'],
        parent: entity['parent'],
        count: entity['count'],
        filter: entity['filter'],
      );
    } catch (e) {
      return Thematic();
    }
  }
}
