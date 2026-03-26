import 'package:dartz/dartz.dart';

import '../../modals/notification/notification.dart';

abstract class NotificationRepository {
  Future<Either<String, List<Notification>>> getNotification(int idProject);

  Future<Either<String, List<Notification>>> getNotificationFromServer(int idProject);

  Future<Either<String, List<Notification>>> getNotificationFromLocal(int idProject);

  Future<Either<String, bool>> markNotificationAsRead(int notificationId, int idProject);

  Future<Either<String, bool>> markNotificationAsUnread(int notificationId, int idProject);

  Future<Either<String, bool>> markAllNotificationsAsRead(int idProject);

  Future<Either<String, int>> getUnreadNotificationsCount(int idProject);

  Future<Either<String, List<Notification>>> getUnreadNotifications(int idProject);

  Future<Either<String, bool>> deleteNotification(int notificationId, int idProject);

  Future<Either<String, bool>> restoreNotification(int notificationId, int idProject);

  Future<Either<String, bool>> permanentlyDeleteNotification(int notificationId, int idProject);

  Future<Either<String, List<Notification>>> getDeletedNotifications(int idProject);

}
