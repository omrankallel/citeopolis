import '../../../domain/modals/term.dart';
import '../../entities/term_entity.dart';

class TermMapper {
  static Term transformToModel(final TermEntity entity) {
    try {
      return Term(
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
      return Term();
    }
  }
}
