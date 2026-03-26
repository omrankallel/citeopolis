import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/tile_extension.dart';
import '../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../design_system/atoms/atom_error_connexion.dart';
import '../../../../design_system/atoms/atom_text.dart';
import '../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../design_system/organism/organism_content_card.dart';
import '../../../../router/navigation_service.dart';
import '../../../../router/routes.dart';
import '../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../domain/modals/notification/notification.dart' as notification;
import '../viewmodel/notification/notification_list_view_model.dart';
import '../viewmodel/notifications_view_model.dart';
import '../viewmodel/thematic/thematic_list_view_model.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          final notificationsViewModel = ref.watch(notificationsProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          final unreadCount = ref.watch(notificationsViewModel.unreadCount);
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              key: notificationsViewModel.scaffoldKey,
              endDrawer: AtomEndDrawer(
                scaffoldKey: notificationsViewModel.scaffoldKey,
                textFilter: 'Filtrer les Notifications',
                isDarkMode: isDarkMode,
                thematicListFilter: ref.watch(notificationsViewModel.thematics).map((e) => e.name ?? '').toList(),
                selectedList: ref.watch(notificationsViewModel.selectedList),
                onSelected: (value, index) {
                  ref.read(notificationsViewModel.selectedList.notifier).update(
                        (state) => [
                          for (int j = 0; j < state.length; j++)
                            if (j == index) state[j] = value else state[j] = state[j],
                        ],
                      );
                },
                startDate: notificationsViewModel.startDate,
                endDate: notificationsViewModel.endDate,
                onApplyFilters: () {
                  notificationsViewModel.applyFilters(ref);
                },
                onClearFilters: () {
                  notificationsViewModel.clearFilters(ref);
                },
              ),
              appBar: AppBarWithSearchSwitch(
                fieldHintText: 'Rechercher ...',
                customTextEditingController: notificationsViewModel.searchController,
                clearSearchIcon: Icons.clear,
                onChanged: (text) => notificationsViewModel.onSearchTextChanged(ref, text),
                onCleared: () => notificationsViewModel.clearSearch(ref),
                animation: AppBarAnimationSlideLeft.call,
                appBarBuilder: (context) => AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  scrolledUnderElevation: 0,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => NavigationService.back(context, ref),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                      ),
                    ),
                  ),
                  actions: [
                    const AppBarSearchButton(),
                    20.pw,
                    InkWell(
                      child: bg.Badge(
                        badgeAnimation: const bg.BadgeAnimation.fade(
                          animationDuration: Duration(seconds: 1),
                          loopAnimation: true,
                        ),
                        showBadge: unreadCount > 0,
                        badgeContent: Text(
                          unreadCount.toString(),
                          style: AppFonts.poppinsI1Regular.copyWith(
                            color: kNeutralColor100,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        position: bg.BadgePosition.custom(start: 12, top: -7),
                        badgeStyle: const bg.BadgeStyle(
                          badgeColor: Color(0xFFB71C1C),
                        ),
                        child: const Icon(
                          Icons.notifications_none_sharp,
                          size: 23,
                        ),
                      ),
                    ),
                    25.pw,
                    InkWell(
                      onTap: () {},
                      child: const bg.Badge(
                        showBadge: false,
                        child: WidgetPopupMenu(),
                      ),
                    ),
                    20.pw,
                  ],
                ),
              ),
              body: ref.watch(thematicListProvider).maybeMap(
                    orElse: () => const Center(child: CircularProgressIndicator()),
                    success: (thematics) {
                      thematics.data.fold((l) => Container(), (data) async {
                        notificationsViewModel.initialiseThematic(ref, data);
                      });
                      final displayedNotifications = ref.watch(notificationsViewModel.filteredNotifications);

                      return ref.watch(notificationListProvider).maybeMap(
                            orElse: () => const Center(child: CircularProgressIndicator()),
                            success: (notifications) {
                              notifications.data.fold((l) => Container(), (data) async {
                                notificationsViewModel.initialiseNotification(ref, data);
                              });
                              return RefreshIndicator(
                                onRefresh: () async {
                                  notificationsViewModel.statusConnectionNotification = null;
                                  await Future.wait([
                                    ref.read(notificationViewModelStateNotifierProvider.notifier).refreshFromServer(),
                                    ref.read(thematicViewModelStateNotifierProvider.notifier).refreshFromServer(),
                                  ]);
                                },
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        20.ph,
                                        Row(
                                          children: [
                                            Text(
                                              'Notifications',
                                              style: Theme.of(context).textTheme.headlineLarge,
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap: () => notificationsViewModel.scaffoldKey.currentState?.openEndDrawer(),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                width: 90,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  border: Border.all(
                                                    color: const Color(0xFF757579),
                                                  ),
                                                ),
                                                child: AtomTextIcon(
                                                  data: 'Filtrer',
                                                  iconData: Icons.sort,
                                                  spacing: 8,
                                                  style: Theme.of(context).textTheme.labelLarge,
                                                  sizeIcon: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        10.ph,
                                        if (unreadCount > 0)
                                          Row(
                                            children: [
                                              const Spacer(),
                                              InkWell(
                                                onTap: () async {
                                                  final projectId = int.parse(ProdConfig().projectId);
                                                  await notificationsViewModel.markAllNotificationsAsRead(ref, projectId);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(12.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    color: isDarkMode ? primaryDark.withValues(alpha: 0.1) : primaryLight.withValues(alpha: 0.1),
                                                    border: Border.all(
                                                      color: isDarkMode ? primaryDark : primaryLight,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Tout marquer comme lu',
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                          color: isDarkMode ? primaryDark : primaryLight,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        26.ph,
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: displayedNotifications.length,
                                          itemBuilder: (context, index) => Consumer(
                                            builder: (context, ref, child) {
                                              final notificationsViewModel = ref.watch(notificationsProvider);
                                              final notification = displayedNotifications[index];
                                              final isUnread = !notification.isRead;

                                              return Slidable(
                                                key: Key('Item ${index + 1}'),
                                                startActionPane: ActionPane(
                                                  extentRatio: 0.2,
                                                  dragDismissible: false,
                                                  motion: CustomMotion(
                                                    onOpen: () {
                                                      ref.watch(notificationsViewModel.listSlid.notifier).update(
                                                            (state) => [
                                                              for (int j = 0; j < state.length; j++)
                                                                if (j == index) state[j] = true else state[j] = state[j],
                                                            ],
                                                          );
                                                    },
                                                    onClose: () {
                                                      ref.watch(notificationsViewModel.listSlid.notifier).update(
                                                            (state) => [
                                                              for (int j = 0; j < state.length; j++)
                                                                if (j == index) state[j] = false else state[j] = state[j],
                                                            ],
                                                          );
                                                    },
                                                    motionWidget: InkWell(
                                                      onTap: () async {
                                                        final projectId = int.parse(ProdConfig().projectId);
                                                        await notificationsViewModel.deleteNotification(
                                                          ref,
                                                          notification.id!,
                                                          projectId,
                                                        );
                                                        final message = 'Notification supprimée';
                                                        if (context.mounted) {
                                                          Helpers.showSnackBar(ref.context, message, Colors.green);
                                                        }
                                                      },
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                                                        decoration: const BoxDecoration(
                                                          color: Color(0xFFB3261E),
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(10.0),
                                                            bottomLeft: Radius.circular(10.0),
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(0x26000000),
                                                              blurRadius: 23.2,
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Icon(
                                                          Icons.delete_outline_outlined,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  children: [],
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    if (isUnread && notification.id != null) {
                                                      final projectId = int.parse(ProdConfig().projectId);
                                                      await notificationsViewModel.markNotificationAsRead(
                                                        ref,
                                                        notification.id!,
                                                        projectId,
                                                      );
                                                    }
                                                    if (context.mounted) {
                                                      if ((notification.typeLink ?? '') == '1') {
                                                        await context.redirectToTile(ref, notification.idTile ?? '', true);
                                                      } else if ((notification.typeLink ?? '') == '2') {
                                                        NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: notification.urlLink ?? '');
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: isUnread ? 490 : 480,
                                                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode ? onPrimaryDark : onPrimaryLight,
                                                      borderRadius: ref.watch(notificationsViewModel.listSlid)[index]
                                                          ? null
                                                          : const BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                      boxShadow: [
                                                        const BoxShadow(
                                                          color: Color(0x26000000),
                                                          blurRadius: 23.2,
                                                        ),
                                                      ],
                                                      border: isUnread
                                                          ? Border.all(
                                                              color: isDarkMode ? primaryDark.withValues(alpha: 0.8) : primaryLight.withValues(alpha: 0.8),
                                                              width: 2.0,
                                                            )
                                                          : null,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        OrganismContentCard(
                                                          backgroundColor: isDarkMode ? onPrimaryDark : onPrimaryLight,
                                                          base64ImageData: notification.image,
                                                          labelImage: notification.image ?? ''.split('/').last,
                                                          localImagePath: notification.localPath,
                                                          thematic: notification.thematic?.map((e) => e.name).toList().join(', ') ?? '',
                                                          chapeau: notification.title ?? '',
                                                          sizeImage: const Size(double.infinity, 160),
                                                          date: (notification.displayStartDateNotif ?? '').isEmpty ? '' : Helpers.convertDateAmPmPreview(notification.displayStartDateNotif ?? ''),
                                                          dateAbove: true,
                                                          styleDate: Theme.of(context).textTheme.labelSmall,
                                                          details: notification.body,
                                                          styleDetails: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                                              ),
                                                          searchQuery: ref.watch(notificationsViewModel.searchText),
                                                          isDarkMode: isDarkMode,
                                                        ),
                                                        if (isUnread)
                                                          Positioned(
                                                            top: 12,
                                                            right: 12,
                                                            child: Container(
                                                              width: 12,
                                                              height: 12,
                                                              decoration: BoxDecoration(
                                                                color: isDarkMode ? primaryDark : primaryLight,
                                                                shape: BoxShape.circle,
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: Color(0x40000000),
                                                                    blurRadius: 4,
                                                                    offset: Offset(0, 2),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        if (isUnread && _isRecentNotification(notification))
                                                          Positioned(
                                                            top: 12,
                                                            left: 12,
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFB71C1C),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: AtomText(
                                                                data: 'Nouveau',
                                                                style: AppFonts.poppinsI1Regular.copyWith(
                                                                  color: Colors.white,
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            error: (error) => AtomErrorConnexion(
                              onTap: () {
                                ref.read(notificationViewModelStateNotifierProvider.notifier).getNotificationFromLocal();
                              },
                            ),
                          );
                    },
                    error: (error) => AtomErrorConnexion(
                      onTap: () {
                        ref.read(thematicViewModelStateNotifierProvider.notifier).getThematicFromLocal();
                      },
                    ),
                  ),
            ),
          );
        },
      );
}

bool _isRecentNotification(notification.Notification notif) {
  if (notif.displayStartDateNotif == null || notif.displayStartDateNotif!.isEmpty) {
    return false;
  }

  try {
    DateTime notificationDate;

    try {
      notificationDate = DateTime.parse(notif.displayStartDateNotif!);
    } catch (e) {
      try {
        notificationDate = DateFormat('dd/MM/yyyy').parse(notif.displayStartDateNotif!);
      } catch (e2) {
        try {
          notificationDate = DateFormat('yyyy-MM-dd').parse(notif.displayStartDateNotif!);
        } catch (e3) {
          return false;
        }
      }
    }

    final now = DateTime.now();
    final difference = now.difference(notificationDate);

    return difference.inHours < 24;
  } catch (e) {
    return false;
  }
}

class CustomMotion extends StatefulWidget {
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final Widget motionWidget;

  const CustomMotion({
    required this.onOpen,
    required this.onClose,
    required this.motionWidget,
    super.key,
  });

  @override
  CustomMotionState createState() => CustomMotionState();
}

class CustomMotionState extends State<CustomMotion> {
  SlidableController? controller;
  VoidCallback? myListener;
  bool isClosed = true;

  void animationListener() {
    if (controller == null) return;

    if (controller!.ratio == 0 && !isClosed) {
      isClosed = true;
      widget.onClose();
    }

    if (controller!.ratio == controller!.startActionPaneExtentRatio && isClosed) {
      isClosed = false;
      widget.onOpen();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    myListener = animationListener;
    controller!.animation.addListener(myListener!);
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.animation.removeListener(myListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.motionWidget;
}
