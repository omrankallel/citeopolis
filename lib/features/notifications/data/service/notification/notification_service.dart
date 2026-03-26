import 'package:dartz/dartz.dart';

import '../../entities/notification/notification_entity.dart';

abstract class NotificationService {
  Future<Either<String, NotificationListEntity>> getNotification(int idProject);
}
