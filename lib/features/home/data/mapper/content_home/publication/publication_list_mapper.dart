import '../../../../domain/modals/content_home/publication.dart';
import '../../../entities/content_home/publication_entity.dart';
import 'publication_mapper.dart';

class PublicationListMapper {
  static List<Publication> transformToModel(final PublicationListEntity entities) => entities
      .map(
        (entity) => PublicationMapper.transformToModel(entity),
      )
      .toList();
}
