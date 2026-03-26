import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/services/image_app/image_service.dart';
import '../../../../../core/services/image_app/image_service_impl.dart';
import '../../../domain/repositories/notification/notification_repository.dart';
import '../../service/notification/notification_service.dart';
import '../../service/notification/notification_service_impl.dart';
import 'notification_repository_impl.dart';

final notificationProvider = Provider<NotificationService>((_) => NotificationServiceImpl());
final imageServiceProvider = Provider<ImageService>((_) => ImageServiceImpl());

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    ref.watch(notificationProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(imageServiceProvider),
  ),
);
