import '../../../../../../core/core.dart';
import '../../../domain/modals/notification/notification.dart';
import '../../entities/notification/notification_entity.dart';
import '../thematic/thematic_list_mapper.dart';

class NotificationMapper {
  static Notification transformToModel(final NotificationEntity entity) {
    try {
      return Notification(
        id: entity['ID'],
        title: entity['title'],
        body: entity['body'],
        typeLink: entity['type_link'],
        idTile: Helpers.isNullEmptyOrFalse(entity['tile']) || entity['tile'].runtimeType == bool || entity['tile'].runtimeType == String? null : entity['tile']['id'],
        urlLink: entity['url_link'],
        displayStartDateNotif: entity['display_start_date_notif'],
        displayEndDateNotif: entity['display_end_date_notif'],
        publishNotif: entity['publish_notif'],
        status: entity['status'],
        thematic: Helpers.isNullEmptyOrFalse(entity['notification-thematic']) ? [] : ThematicListMapper.transformToModel(entity['notification-thematic']),
        image: entity['image'].runtimeType == String ? entity['image'] : null,
      );
    } catch (e) {
      return Notification();
    }
  }
}
