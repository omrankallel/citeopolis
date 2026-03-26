import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prod_config.dart';
import '../../viewmodel/notifications_view_model.dart';

class NotificationBadgeWidget extends ConsumerWidget {
  final Widget child;
  final bool showBadge;

  const NotificationBadgeWidget({
    required this.child,
    super.key,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showBadge) {
      return child;
    }

    final unreadCount = ref.watch(unreadCountStateProvider);

    return bg.Badge(
      showBadge: unreadCount > 0,
      badgeContent: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      badgeStyle: const bg.BadgeStyle(
        badgeColor: Color(0xFFB71C1C),
      ),
      position: bg.BadgePosition.topEnd(end: -8),
      child: child,
    );
  }
}

class NotificationIconBadge extends ConsumerWidget {
  final IconData iconData;
  final double size;
  final VoidCallback? onTap;
  final Color? iconColor;

  const NotificationIconBadge({
    required this.iconData,
    super.key,
    this.size = 24.0,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountStateProvider);

    return InkWell(
      onTap: onTap,
      child: bg.Badge(
        showBadge: unreadCount > 0,
        badgeAnimation: const bg.BadgeAnimation.fade(
          animationDuration: Duration(seconds: 1),
          loopAnimation: true,
        ),
        badgeContent: Text(
          unreadCount > 99 ? '99+' : unreadCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        position: bg.BadgePosition.custom(start: size * 0.5, top: -7),
        badgeStyle: const bg.BadgeStyle(
          badgeColor: Color(0xFFB71C1C),
        ),
        child: Icon(
          iconData,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}

class SyncedNotificationIconBadge extends ConsumerWidget {
  final IconData iconData;
  final double size;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SyncedNotificationIconBadge({
    required this.iconData,
    super.key,
    this.size = 24.0,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = int.parse(ProdConfig().projectId);

    final stateUnreadCount = ref.watch(unreadCountStateProvider);

    final futureUnreadCount = ref.watch(unreadNotificationsCountProvider(projectId));

    return InkWell(
      onTap: onTap,
      child: futureUnreadCount.when(
        data: (futureCount) {
          final displayCount = stateUnreadCount != 0 ? stateUnreadCount : futureCount;

          return bg.Badge(
            showBadge: displayCount > 0,
            badgeAnimation: const bg.BadgeAnimation.fade(
              animationDuration: Duration(seconds: 1),
              loopAnimation: true,
            ),
            badgeContent: Text(
              displayCount > 99 ? '99+' : displayCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            position: bg.BadgePosition.custom(start: size * 0.5, top: -7),
            badgeStyle: const bg.BadgeStyle(
              badgeColor: Color(0xFFB71C1C),
            ),
            child: Icon(
              iconData,
              size: size,
              color: iconColor,
            ),
          );
        },
        loading: () => bg.Badge(
          showBadge: stateUnreadCount > 0,
          badgeContent: Text(
            stateUnreadCount > 99 ? '99+' : stateUnreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          position: bg.BadgePosition.custom(start: size * 0.5, top: -7),
          badgeStyle: const bg.BadgeStyle(
            badgeColor: Color(0xFFB71C1C),
          ),
          child: Icon(
            iconData,
            size: size,
            color: iconColor,
          ),
        ),
        error: (error, stack) => Icon(
          iconData,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}

mixin NotificationCountMixin {
  int getUnreadNotificationsCount(WidgetRef ref) => ref.watch(unreadCountStateProvider);

  bool hasUnreadNotifications(WidgetRef ref) => getUnreadNotificationsCount(ref) > 0;

  String formatNotificationCount(int count) => count > 99 ? '99+' : count.toString();

  void syncNotificationCount(WidgetRef ref) {
    final projectId = int.parse(ProdConfig().projectId);
    ref.invalidate(unreadNotificationsCountProvider(projectId));
  }
}
