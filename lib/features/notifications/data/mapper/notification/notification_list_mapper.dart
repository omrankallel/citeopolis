import '../../../domain/modals/notification/notification.dart';
import '../../entities/notification/notification_entity.dart';
import 'notification_mapper.dart';

class NotificationListMapper {
  static List<Notification> transformToModel(final NotificationListEntity entities) => entities
      .map(
        (entity) => NotificationMapper.transformToModel(entity),
      )
      .toList();
}
