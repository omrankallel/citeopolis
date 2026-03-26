import 'package:dartz/dartz.dart' as st;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/state/state.dart';
import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../domain/modals/notification/notification.dart';
import '../../../domain/repositories/notification/notification_domain_module.dart';
import '../../../domain/usecases/notification/notification_use_case.dart';

final notificationListProvider = Provider<State<st.Either<String, List<Notification>>>>((ref) {
  final notificationAppState = ref.watch(notificationViewModelStateNotifierProvider);
  return notificationAppState.state.when(
    init: () => const State.init(),
    success: (notification) => State.success(notification),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final notificationViewModelStateNotifierProvider = StateNotifierProvider<NotificationViewModel, DataState<List<Notification>>>(
  (ref) => NotificationViewModel(
    ref.watch(notificationUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class NotificationViewModel extends StateNotifier<DataState<List<Notification>>> {
  final NotificationUseCase _notificationUseCase;
  final ConnectivityService _connectivityService;

  NotificationViewModel(this._notificationUseCase, this._connectivityService) : super(const DataState<List<Notification>>(state: State.init())) {
    getNotificationFromLocal();
  }

  Future<void> getNotificationFromLocal() async {
    try {
      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final notification = await _notificationUseCase.getNotificationFromLocal(int.parse(idProject));

      if (mounted) {
        notification.fold(
          (error) {
            state = state.copyWith(
              state: State.error(Exception('Données locales non disponibles: $error')),
              isFromCache: true,
            );
          },
          (r) {
            state = state.copyWith(
              state: State.success(notification),
              isFromCache: true,
            );
          },
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(
        state: State.error(e),
        isFromCache: true,
      );
    }
  }

  Future<void> refreshFromServer() async {
    try {
      final hasConnection = await _connectivityService.hasConnection();

      if (!hasConnection) {
        await getNotificationFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final notification = await _notificationUseCase.getNotificationFromServer(int.parse(idProject));

      if (mounted) {
        notification.fold(
          (error) {
            getNotificationFromLocal();
          },
          (r) {
            state = state.copyWith(
              state: State.success(notification),
              isFromCache: false,
            );
          },
        );
      }
    } on Exception {
      await getNotificationFromLocal();
    }
  }

  Future<void> getNotification() async {
    await getNotificationFromLocal();
  }
}
