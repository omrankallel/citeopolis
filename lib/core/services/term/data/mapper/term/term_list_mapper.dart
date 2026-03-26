import '../../../domain/modals/term.dart';
import '../../entities/term_entity.dart';
import 'term_mapper.dart';

class TermListMapper {
  static List<Term> transformToModel(final TermListEntity entities) => entities
      .map(
        (entity) => TermMapper.transformToModel(entity),
      )
      .toList();
}
