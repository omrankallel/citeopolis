import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../data/repositories/notification/notification_data_module.dart';
import '../../domain/modals/notification/notification.dart' as notification;
import '../../domain/modals/thematic/thematic.dart';
import '../../domain/repositories/notification/notification_repository.dart';

final notificationsProvider = ChangeNotifierProvider(
  (ref) => NotificationsProvider(
    ref.watch(notificationRepositoryProvider),
  ),
);

final unreadCountStateProvider = StateProvider<int>((ref) => 0);

final unreadNotificationsCountProvider = FutureProvider.family<int, int>((ref, idProject) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getUnreadNotificationsCount(idProject);
  final count = result.fold((error) => 0, (count) => count);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(unreadCountStateProvider.notifier).state = count;
  });

  return count;
});

final unreadNotificationsProvider = FutureProvider.family<List<notification.Notification>, int>((ref, idProject) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getUnreadNotifications(idProject);
  return result.fold((error) => [], (notifications) => notifications);
});

final deletedNotificationsProvider = FutureProvider.family<List<notification.Notification>, int>((ref, idProject) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getDeletedNotifications(idProject);
  return result.fold((error) => [], (notifications) => notifications);
});

class NotificationsProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationsProvider(this._notificationRepository);

  final searchText = StateProvider<String>((ref) => '');
  final searchController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedList = StateProvider<List<bool>>((ref) => []);
  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  final listSlid = StateProvider<List<bool>>((ref) => []);

  final thematics = StateProvider<List<Thematic>>((ref) => []);
  final notifications = StateProvider<List<notification.Notification>>((ref) => []);
  final filteredNotifications = StateProvider<List<notification.Notification>>((ref) => []);

  final unreadCount = StateProvider<int>((ref) => 0);

  bool? statusConnectionThematic;
  bool? statusConnectionNotification;

  List<notification.Notification> _originalNotifications = [];
  bool _hasActiveFilters = false;

  void initialiseThematic(WidgetRef ref, List<Thematic> listThematics) {
    final isConnected = ref.watch(isConnectedProvider);
    if (statusConnectionThematic != isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(selectedList.notifier).state.clear();
        ref.read(thematics.notifier).state.clear();
        ref.read(thematics.notifier).state = List<Thematic>.from(listThematics.map((item) => item.copyWith()));
        ref.read(selectedList.notifier).state = listThematics.map((e) => false).toList();
        statusConnectionThematic = isConnected;
      });
    }
  }

  void initialiseNotification(WidgetRef ref, List<notification.Notification> listNotifications) {
    final isConnected = ref.watch(isConnectedProvider);
    if (statusConnectionNotification != isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _originalNotifications = List<notification.Notification>.from(listNotifications.map((item) => item.copyWith()));
        ref.read(listSlid.notifier).state.clear();
        ref.read(notifications.notifier).state.clear();
        ref.read(notifications.notifier).state = List<notification.Notification>.from(_originalNotifications);
        ref.read(filteredNotifications.notifier).state = List<notification.Notification>.from(_originalNotifications);
        ref.read(listSlid.notifier).state = listNotifications.map((e) => false).toList();

        await _updateUnreadCount(ref);

        statusConnectionNotification = isConnected;
      });
    }
  }

  Future<void> _updateUnreadCount(WidgetRef ref) async {
    final unreadNotifications = _originalNotifications.where((notification) => !notification.isRead).length;
    ref.read(unreadCount.notifier).state = unreadNotifications;

    ref.read(unreadCountStateProvider.notifier).state = unreadNotifications;
  }

  Future<void> deleteNotification(WidgetRef ref, int notificationId, int idProject) async {
    try {
      final result = await _notificationRepository.deleteNotification(notificationId, idProject);
      result.fold(
        (error) => debugPrint('Erreur lors de la suppression: $error'),
        (success) async {
          if (success) {
            _removeNotificationFromLists(ref, notificationId);
            await _updateUnreadCount(ref);

            _closeAllSlides(ref);

            ref.invalidate(unreadNotificationsCountProvider(idProject));
            ref.invalidate(unreadNotificationsProvider(idProject));
            ref.invalidate(deletedNotificationsProvider(idProject));
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression: $e');
    }
  }

  void _closeAllSlides(WidgetRef ref) {
    final currentSlides = ref.read(listSlid.notifier).state;
    if (currentSlides.isNotEmpty) {
      ref.read(listSlid.notifier).state = List.generate(currentSlides.length, (index) => false);
    }
  }

  void _removeNotificationFromLists(WidgetRef ref, int notificationId) {
    final currentFilteredNotifications = ref.read(filteredNotifications.notifier).state;
    final notificationIndex = currentFilteredNotifications.indexWhere((n) => n.id == notificationId);

    _originalNotifications.removeWhere((n) => n.id == notificationId);

    final currentNotifications = ref.read(notifications.notifier).state;
    final updatedNotifications = currentNotifications.where((n) => n.id != notificationId).toList();
    ref.read(notifications.notifier).state = updatedNotifications;

    final updatedFilteredNotifications = currentFilteredNotifications.where((n) => n.id != notificationId).toList();
    ref.read(filteredNotifications.notifier).state = updatedFilteredNotifications;

    final currentSlides = ref.read(listSlid.notifier).state;
    if (currentSlides.isNotEmpty && notificationIndex != -1 && notificationIndex < currentSlides.length) {
      final updatedSlides = [...currentSlides];
      updatedSlides.removeAt(notificationIndex);
      ref.read(listSlid.notifier).state = updatedSlides;
    } else {
      ref.read(listSlid.notifier).state = List.generate(updatedFilteredNotifications.length, (index) => false);
    }
  }

  Future<void> markNotificationAsRead(WidgetRef ref, int notificationId, int idProject) async {
    try {
      final result = await _notificationRepository.markNotificationAsRead(notificationId, idProject);
      result.fold(
        (error) => debugPrint('Erreur lors du marquage comme lu: $error'),
        (success) async {
          if (success) {
            _updateNotificationReadStatus(ref, notificationId, true);
            await _updateUnreadCount(ref);

            ref.invalidate(unreadNotificationsCountProvider(idProject));
            ref.invalidate(unreadNotificationsProvider(idProject));
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur lors du marquage comme lu: $e');
    }
  }

  Future<void> markNotificationAsUnread(WidgetRef ref, int notificationId, int idProject) async {
    try {
      final result = await _notificationRepository.markNotificationAsUnread(notificationId, idProject);
      result.fold(
        (error) => debugPrint('Erreur lors du marquage comme non lu: $error'),
        (success) async {
          if (success) {
            _updateNotificationReadStatus(ref, notificationId, false);
            await _updateUnreadCount(ref);

            ref.invalidate(unreadNotificationsCountProvider(idProject));
            ref.invalidate(unreadNotificationsProvider(idProject));
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur lors du marquage comme non lu: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(WidgetRef ref, int idProject) async {
    try {
      final result = await _notificationRepository.markAllNotificationsAsRead(idProject);
      result.fold(
        (error) => debugPrint('Erreur lors du marquage de toutes les notifications comme lues: $error'),
        (success) async {
          if (success) {
            _updateAllNotificationsReadStatus(ref, true);
            await _updateUnreadCount(ref);

            ref.invalidate(unreadNotificationsCountProvider(idProject));
            ref.invalidate(unreadNotificationsProvider(idProject));
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur lors du marquage de toutes les notifications comme lues: $e');
    }
  }

  void _updateNotificationReadStatus(WidgetRef ref, int notificationId, bool isRead) {
    final originalIndex = _originalNotifications.indexWhere((n) => n.id == notificationId);
    if (originalIndex != -1) {
      _originalNotifications[originalIndex] = _originalNotifications[originalIndex].copyWith(
        isRead: isRead,
        readAt: isRead ? DateTime.now() : null,
      );
    }

    final currentNotifications = ref.read(notifications.notifier).state;
    final notificationIndex = currentNotifications.indexWhere((n) => n.id == notificationId);
    if (notificationIndex != -1) {
      final updatedNotifications = [...currentNotifications];
      updatedNotifications[notificationIndex] = updatedNotifications[notificationIndex].copyWith(
        isRead: isRead,
        readAt: isRead ? DateTime.now() : null,
      );
      ref.read(notifications.notifier).state = updatedNotifications;
    }

    final currentFilteredNotifications = ref.read(filteredNotifications.notifier).state;
    final filteredIndex = currentFilteredNotifications.indexWhere((n) => n.id == notificationId);
    if (filteredIndex != -1) {
      final updatedFilteredNotifications = [...currentFilteredNotifications];
      updatedFilteredNotifications[filteredIndex] = updatedFilteredNotifications[filteredIndex].copyWith(
        isRead: isRead,
        readAt: isRead ? DateTime.now() : null,
      );
      ref.read(filteredNotifications.notifier).state = updatedFilteredNotifications;
    }
  }

  void _updateAllNotificationsReadStatus(WidgetRef ref, bool isRead) {
    final now = isRead ? DateTime.now() : null;

    _originalNotifications = _originalNotifications
        .map(
          (notification) => notification.copyWith(isRead: isRead, readAt: now),
        )
        .toList();

    final updatedNotifications = ref
        .read(notifications.notifier)
        .state
        .map(
          (notification) => notification.copyWith(isRead: isRead, readAt: now),
        )
        .toList();
    ref.read(notifications.notifier).state = updatedNotifications;

    final updatedFilteredNotifications = ref
        .read(filteredNotifications.notifier)
        .state
        .map(
          (notification) => notification.copyWith(isRead: isRead, readAt: now),
        )
        .toList();
    ref.read(filteredNotifications.notifier).state = updatedFilteredNotifications;
  }

  int getUnreadNotificationsCount() => _originalNotifications.where((notification) => !notification.isRead).length;

  List<notification.Notification> getUnreadNotifications() => _originalNotifications.where((notification) => !notification.isRead).toList();

  void applyFilters(WidgetRef ref) {
    final selectedThematicIndices = <int>[];
    final selectedStates = ref.read(selectedList.notifier).state;
    final allThematics = ref.read(thematics.notifier).state;

    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedThematicIndices.add(i);
      }
    }

    final selectedThematicNames = selectedThematicIndices.map((index) => allThematics[index].name?.toLowerCase()).where((name) => name != null).cast<String>().toList();

    final startDateText = startDate.text.trim();
    final endDateText = endDate.text.trim();

    DateTime? filterStartDate;
    DateTime? filterEndDate;

    if (startDateText.isNotEmpty) {
      try {
        filterStartDate = DateFormat('dd/MM/yyyy').parse(startDateText);
      } catch (e) {
        debugPrint('Erreur parsing date début: $e');
      }
    }

    if (endDateText.isNotEmpty) {
      try {
        filterEndDate = DateFormat('dd/MM/yyyy').parse(endDateText);
        filterEndDate = DateTime(filterEndDate.year, filterEndDate.month, filterEndDate.day, 23, 59, 59);
      } catch (e) {
        debugPrint('Erreur parsing date fin: $e');
      }
    }

    _hasActiveFilters = selectedThematicNames.isNotEmpty || filterStartDate != null || filterEndDate != null;

    if (!_hasActiveFilters) {
      ref.read(filteredNotifications.notifier).state = List<notification.Notification>.from(_originalNotifications);
      return;
    }

    final filtered = _originalNotifications.where((notification) {
      bool matchesThematic = true;
      bool matchesDate = true;

      if (selectedThematicNames.isNotEmpty) {
        matchesThematic = false;
        if (notification.thematic != null && notification.thematic!.isNotEmpty) {
          for (final thematic in notification.thematic!) {
            if (thematic.name != null && selectedThematicNames.contains(thematic.name!.toLowerCase())) {
              matchesThematic = true;
              break;
            }
          }
        }
      }

      if (filterStartDate != null || filterEndDate != null) {
        if (notification.displayStartDateNotif != null && notification.displayStartDateNotif!.isNotEmpty) {
          try {
            DateTime notificationDate;

            try {
              notificationDate = DateTime.parse(notification.displayStartDateNotif!);
            } catch (e) {
              try {
                notificationDate = DateFormat('dd/MM/yyyy').parse(notification.displayStartDateNotif!);
              } catch (e2) {
                try {
                  notificationDate = DateFormat('yyyy-MM-dd').parse(notification.displayStartDateNotif!);
                } catch (e3) {
                  matchesDate = false;
                  return false;
                }
              }
            }

            if (filterStartDate != null && notificationDate.isBefore(filterStartDate)) {
              matchesDate = false;
            }
            if (filterEndDate != null && notificationDate.isAfter(filterEndDate)) {
              matchesDate = false;
            }
          } catch (e) {
            matchesDate = false;
          }
        } else {
          matchesDate = false;
        }
      }

      return matchesThematic && matchesDate;
    }).toList();

    ref.read(filteredNotifications.notifier).state = filtered;
  }

  void clearFilters(WidgetRef ref) {
    final thematics = ref.read(selectedList.notifier).state;
    ref.read(selectedList.notifier).state = List.generate(thematics.length, (index) => false);

    startDate.clear();
    endDate.clear();

    ref.read(filteredNotifications.notifier).state = List<notification.Notification>.from(_originalNotifications);

    _hasActiveFilters = false;
  }

  bool get hasActiveFilters => _hasActiveFilters;

  int getActiveFiltersCount(WidgetRef ref) {
    int count = 0;

    final selectedStates = ref.read(selectedList.notifier).state;
    count += selectedStates.where((selected) => selected).length;

    if (startDate.text.trim().isNotEmpty) count++;
    if (endDate.text.trim().isNotEmpty) count++;

    return count;
  }

  bool _matchesSearchQuery(notification.Notification notification, String query) {
    if ((notification.title ?? '').toLowerCase().contains(query)) {
      return true;
    }

    if ((notification.body ?? '').toLowerCase().contains(query)) {
      return true;
    }

    if (notification.thematic != null && notification.thematic!.isNotEmpty) {
      for (final thematic in notification.thematic!) {
        if ((thematic.name ?? '').toLowerCase().contains(query)) {
          return true;
        }
      }
    }

    if ((notification.status ?? '').toLowerCase().contains(query)) {
      return true;
    }

    if ((notification.typeLink ?? '').toLowerCase().contains(query)) {
      return true;
    }

    if ((notification.urlLink ?? '').toLowerCase().contains(query)) {
      return true;
    }

    if ((notification.idTile ?? '').toLowerCase().contains(query)) {
      return true;
    }

    return false;
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    final normalizedText = text.trim().toLowerCase();

    ref.read(searchText.notifier).state = normalizedText;

    if (normalizedText.isEmpty) {
      ref.read(filteredNotifications.notifier).state = List.from(ref.watch(notifications));
      searchController.clear();
      return;
    }

    final filteredArticles = ref.watch(notifications).where((article) => _matchesSearchQuery(article, normalizedText)).toList();

    if (ref.watch(selectedList).any((element) => element)) {
      applyFilters(ref);
    }

    ref.read(filteredNotifications.notifier).state = filteredArticles;
  }

  void clearSearch(WidgetRef ref) {
    ref.read(searchText.notifier).state = '';
    ref.read(filteredNotifications.notifier).state = ref.read(notifications);
    if (ref.watch(selectedList).any((element) => element)) {
      applyFilters(ref);
    }
  }

  @override
  void dispose() {
    startDate.dispose();
    endDate.dispose();
    super.dispose();
  }
}
