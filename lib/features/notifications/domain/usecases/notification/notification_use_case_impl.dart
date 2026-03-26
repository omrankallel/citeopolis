import 'package:dartz/dartz.dart';

import '../../modals/notification/notification.dart';
import '../../repositories/notification/notification_repository.dart';
import 'notification_use_case.dart';

class NotificationUseCaseImpl implements NotificationUseCase {
  final NotificationRepository _repository;

  const NotificationUseCaseImpl(this._repository);

  @override
  Future<Either<String, List<Notification>>> getNotification(int idProject) => _repository.getNotification(idProject);

  @override
  Future<Either<String, List<Notification>>> getNotificationFromLocal(int idProject) => _repository.getNotificationFromLocal(idProject);

  @override
  Future<Either<String, List<Notification>>> getNotificationFromServer(int idProject) => _repository.getNotificationFromServer(idProject);

  @override
  Future<Either<String, bool>> markNotificationAsRead(int notificationId, int idProject) => _repository.markNotificationAsRead(notificationId, idProject);

  @override
  Future<Either<String, bool>> markNotificationAsUnread(int notificationId, int idProject) => _repository.markNotificationAsUnread(notificationId, idProject);

  @override
  Future<Either<String, bool>> markAllNotificationsAsRead(int idProject) => _repository.markAllNotificationsAsRead(idProject);

  @override
  Future<Either<String, int>> getUnreadNotificationsCount(int idProject) => _repository.getUnreadNotificationsCount(idProject);

  @override
  Future<Either<String, List<Notification>>> getUnreadNotifications(int idProject) => _repository.getUnreadNotifications(idProject);

  @override
  Future<Either<String, bool>> deleteNotification(int notificationId, int idProject) => _repository.deleteNotification(notificationId, idProject);

  @override
  Future<Either<String, bool>> restoreNotification(int notificationId, int idProject) => _repository.restoreNotification(notificationId, idProject);

  @override
  Future<Either<String, bool>> permanentlyDeleteNotification(int notificationId, int idProject) => _repository.permanentlyDeleteNotification(notificationId, idProject);

  @override
  Future<Either<String, List<Notification>>> getDeletedNotifications(int idProject) => _repository.getDeletedNotifications(idProject);
}
