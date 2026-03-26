import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/notification/notification_data_module.dart';
import '../../usecases/notification/notification_use_case.dart';
import '../../usecases/notification/notification_use_case_impl.dart';

final notificationUseCaseProvider = Provider<NotificationUseCase>(
  (ref) => NotificationUseCaseImpl(ref.watch(notificationRepositoryProvider)),
);

final updateNotification = StateProvider<bool>((ref) => false);
