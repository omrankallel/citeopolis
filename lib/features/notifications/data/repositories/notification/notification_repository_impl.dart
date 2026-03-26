import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../core/network/connectivity_provider.dart';
import '../../../../../../core/services/image_app/image_service.dart';
import '../../../../../../core/services/image_app/image_service_impl.dart';
import '../../../../../../core/services/injector.dart';
import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../domain/modals/notification/notification.dart';
import '../../../domain/repositories/notification/notification_repository.dart';
import '../../mapper/notification/notification_list_mapper.dart';
import '../../service/notification/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _notificationService;
  final ConnectivityService _connectivityService;
  final ImageService _imageService;
  final LocalStorageListService<Notification> _notificationStorage = getIt<LocalStorageListService<Notification>>();

  NotificationRepositoryImpl(
    this._notificationService,
    this._connectivityService, [
    ImageService? imageService,
  ]) : _imageService = imageService ?? ImageServiceImpl();

  @override
  Future<Either<String, List<Notification>>> getNotification(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getNotificationFromServer(idProject);
      } else {
        return await getNotificationFromLocal(idProject);
      }
    } catch (e) {
      final localResult = await getNotificationFromLocal(idProject);
      return localResult.fold(
        (localError) => Left('Erreur réseau et locale: $e'),
        (notification) => Right(notification),
      );
    }
  }

  @override
  Future<Either<String, List<Notification>>> getNotificationFromServer(int idProject) async {
    try {
      final notificationList = await _notificationService.getNotification(idProject);

      return notificationList.fold((l) => Left(l), (apiData) async {
        final mappedNotification = NotificationListMapper.transformToModel(apiData);
        final oldData = _notificationStorage.get(idProject.toString());

        await _preserveUserActions(idProject, mappedNotification);
        await _saveAllImagesLocally(mappedNotification, oldData);
        await _deleteObsoleteImages(oldData, mappedNotification);
        await _saveToLocalStorage(idProject, mappedNotification);

        final visibleNotifications = mappedNotification.where((n) => !n.isDeleted).toList();
        return Right(visibleNotifications);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Notification>>> getNotificationFromLocal(int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        await _verifyLocalImages(idProject, localData);
        final visibleNotifications = localData.where((n) => !n.isDeleted).toList();
        return Right(visibleNotifications);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getNotificationFromServer(idProject);
        } else {
          return const Right([]);
        }
      }
    } catch (e) {
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> markNotificationAsRead(int notificationId, int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final notificationIndex = localData.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          localData[notificationIndex] = localData[notificationIndex].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          await _saveToLocalStorage(idProject, localData);
          return const Right(true);
        }
      }
      return const Left('Notification non trouvée');
    } catch (e) {
      return Left('Erreur lors du marquage comme lu: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> markNotificationAsUnread(int notificationId, int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final notificationIndex = localData.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          localData[notificationIndex] = localData[notificationIndex].copyWith(isRead: false);
          await _saveToLocalStorage(idProject, localData);
          return const Right(true);
        }
      }
      return const Left('Notification non trouvée');
    } catch (e) {
      return Left('Erreur lors du marquage comme non lu: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> markAllNotificationsAsRead(int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final updatedNotifications = localData.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
        await _saveToLocalStorage(idProject, updatedNotifications);
        return const Right(true);
      }
      return const Left('Aucune notification trouvée');
    } catch (e) {
      return Left('Erreur lors du marquage de toutes les notifications comme lues: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> deleteNotification(int notificationId, int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final notificationIndex = localData.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          localData[notificationIndex] = localData[notificationIndex].copyWith(
            isDeleted: true,
            deletedAt: DateTime.now(),
          );
          await _saveToLocalStorage(idProject, localData);
          return const Right(true);
        }
      }
      return const Left('Notification non trouvée');
    } catch (e) {
      return Left('Erreur lors de la suppression: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> restoreNotification(int notificationId, int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final notificationIndex = localData.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          localData[notificationIndex] = localData[notificationIndex].copyWith(isDeleted: false);
          await _saveToLocalStorage(idProject, localData);
          return const Right(true);
        }
      }
      return const Left('Notification non trouvée');
    } catch (e) {
      return Left('Erreur lors de la restauration: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> permanentlyDeleteNotification(int notificationId, int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final notificationIndex = localData.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          final notification = localData[notificationIndex];
          if (notification.localPath != null) {
            await _deleteImageFile(notification.localPath!);
          }
          localData.removeAt(notificationIndex);
          await _saveToLocalStorage(idProject, localData);
          return const Right(true);
        }
      }
      return const Left('Notification non trouvée');
    } catch (e) {
      return Left('Erreur lors de la suppression définitive: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Notification>>> getDeletedNotifications(int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final deletedNotifications = localData.where((notification) => notification.isDeleted).toList();
        return Right(deletedNotifications);
      }
      return const Right([]);
    } catch (e) {
      return Left('Erreur lors de la récupération des notifications supprimées: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, int>> getUnreadNotificationsCount(int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final unreadCount = localData.where((n) => !n.isRead && !n.isDeleted).length;
        return Right(unreadCount);
      }
      return const Right(0);
    } catch (e) {
      return Left('Erreur lors du comptage des notifications non lues: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Notification>>> getUnreadNotifications(int idProject) async {
    try {
      final localData = _notificationStorage.get(idProject.toString());
      if (localData != null) {
        final unreadNotifications = localData.where((n) => !n.isRead && !n.isDeleted).toList();
        return Right(unreadNotifications);
      }
      return const Right([]);
    } catch (e) {
      return Left('Erreur lors de la récupération des notifications non lues: ${e.toString()}');
    }
  }

  Future<void> _preserveUserActions(int idProject, List<Notification> newNotifications) async {
    try {
      final existingData = _notificationStorage.get(idProject.toString());
      if (existingData != null) {
        for (int i = 0; i < newNotifications.length; i++) {
          final existingNotification = existingData.firstWhere(
            (existing) => existing.id == newNotifications[i].id,
            orElse: () => Notification(),
          );
          if (existingNotification.id != null) {
            newNotifications[i] = newNotifications[i].copyWith(
              isRead: existingNotification.isRead,
              readAt: existingNotification.readAt,
              isDeleted: existingNotification.isDeleted,
              deletedAt: existingNotification.deletedAt,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la préservation du statut de lecture: $e');
    }
  }

  Future<void> _saveAllImagesLocally(List<Notification> notifications, List<Notification>? oldData) async {
    try {
      final imageTasks = <Future<void>>[];
      for (int i = 0; i < notifications.length; i++) {
        final notification = notifications[i];
        if (notification.image == null) continue;

        final oldNotification = oldData?.firstWhere(
          (o) => o.id == notification.id,
          orElse: () => Notification(),
        );

        if (oldNotification?.localPath != null && oldNotification?.image == notification.image) {
          notifications[i] = notification.copyWith(localPath: oldNotification!.localPath);
          continue;
        }

        final idx = i;
        imageTasks.add(() async {
          final filename = _generateFilename(notification.image!, 'notification');
          final localPath = await _saveImageLocally(notification.image!, filename);
          if (localPath != null) {
            notifications[idx] = notifications[idx].copyWith(localPath: localPath);
          }
        }());
      }
      if (imageTasks.isNotEmpty) await Future.wait(imageTasks);
    } catch (e) {
      debugPrint('Erreur sauvegarde images notifications: $e');
    }
  }

  Future<void> _deleteObsoleteImages(List<Notification>? oldData, List<Notification> newData) async {
    if (oldData == null) return;
    try {
      for (final old in oldData) {
        if (old.localPath == null) continue;
        final stillUsed = newData.any((n) => n.localPath == old.localPath);
        if (!stillUsed) await _deleteImageFile(old.localPath!);
      }
    } catch (e) {
      debugPrint('Erreur suppression images obsolètes notifications: $e');
    }
  }

  Future<void> _deleteImageFile(String localPath) async {
    try {
      await _imageService.deleteLocalImage(localPath);
    } catch (e) {
      debugPrint('Erreur suppression image $localPath: $e');
    }
  }

  String _generateFilename(String imageUrl, String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _getImageExtension(imageUrl);
    return '${type}_$timestamp$extension';
  }

  String _getImageExtension(String imageUrl) {
    if (imageUrl.contains('.jpg') || imageUrl.contains('.jpeg')) return '.jpg';
    if (imageUrl.contains('.png')) return '.png';
    if (imageUrl.contains('.gif')) return '.gif';
    if (imageUrl.contains('.webp')) return '.webp';
    return '.jpg';
  }

  Future<String?> _saveImageLocally(String imageUrl, String filename) async {
    try {
      if (imageUrl.startsWith('http')) {
        return await _imageService.saveImageToLocal(imageUrl, filename);
      } else if (imageUrl.contains('base64') || imageUrl.length > 100) {
        return await _imageService.saveBase64ImageToLocal(imageUrl, filename);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _verifyLocalImages(int idProject, List<Notification> notifications) async {
    try {
      bool hasChanges = false;
      for (int i = 0; i < notifications.length; i++) {
        final notification = notifications[i];
        if (notification.localPath != null) {
          final exists = await _imageService.imageExistsLocally(notification.localPath!);
          if (!exists) {
            notifications[i] = notification.copyWith();
            hasChanges = true;
          }
        }
      }
      if (hasChanges) await _saveToLocalStorage(idProject, notifications);
    } catch (e) {
      debugPrint('Erreur vérification images notifications: $e');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, List<Notification> notifications) async {
    try {
      await _notificationStorage.save(idProject.toString(), notifications);
    } catch (e) {
      debugPrint('Erreur sauvegarde notifications: $e');
    }
  }
}
