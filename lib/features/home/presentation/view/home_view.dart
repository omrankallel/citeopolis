import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/tile_extension.dart';
import '../../../../core/utils/icon_picto_helper.dart';
import '../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../design_system/atoms/atom_error_connexion.dart';
import '../../../../design_system/atoms/atom_item_bottom_navigation_bar.dart';
import '../../../../router/navigation_service.dart';
import '../../../../router/routes.dart';
import '../../../content_home/presentation/viewmodel/content_home_view_model.dart';
import '../../../map/presentation/viewmodel/map_view_model.dart';
import '../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../notifications/presentation/viewmodel/notification/notification_list_view_model.dart';
import '../../../notifications/presentation/viewmodel/notifications_view_model.dart';
import '../../../notifications/presentation/viewmodel/thematic/thematic_list_view_model.dart';
import '../../../tile/presentation/viewmodel/tile_list_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/article/articles_xml_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/directory/directories_xml_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/event/events_xml_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/publication/publications_xml_view_model.dart';
import '../viewmodel/content_home/content_home_list_view_model.dart';
import '../viewmodel/home_view_model.dart';
import '../viewmodel/menu/menu_list_view_model.dart';
import '../viewmodel/tab_bar/tab_bar_list_view_model.dart';
import 'widget/build_widget_drawer.dart';
import 'widget/build_widget_popup_menu.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({this.child, super.key});

  final Widget? child;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> with WidgetsBindingObserver {
  bool _isInitialized = false;
  Key _drawerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotificationCount();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _drawerKey = UniqueKey();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _initializeNotificationCount() async {
    if (_isInitialized) return;

    try {
      final homeViewModel = ref.read(homeProvider);
      await homeViewModel.initializeConfigApp(ref);
      await homeViewModel.initializeNotificationCount(ref);
      _isInitialized = true;
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = ref.watch(homeProvider);
    final contentHomeViewModel = ref.watch(contentHomeProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: homeViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawer: WidgetDrawer(
          key: _drawerKey,
        ),
        drawerEnableOpenDragGesture: false,
        endDrawer: (goRouter.state.name ?? '') == Paths.articleXml
            ? ref.read(articlesXmlProvider).atomEndDrawerArticle(ref, homeViewModel.scaffoldKey, isDarkMode)
            : (goRouter.state.name ?? '') == Paths.directoryXml
                ? ref.read(directoriesXmlProvider).atomEndDrawerDirectory(ref, homeViewModel.scaffoldKey, isDarkMode)
                : (goRouter.state.name ?? '') == Paths.eventsXml
                    ? ref.read(eventsXmlProvider).atomEndDrawerEvent(ref, homeViewModel.scaffoldKey, isDarkMode)
                    : (goRouter.state.name ?? '') == Paths.directoryXml
                        ? ref.read(publicationsXmlProvider).atomEndDrawerPublication(ref, homeViewModel.scaffoldKey, isDarkMode)
                        : (goRouter.state.name ?? '') == Paths.carte
                            ? ref.read(mapProvider).atomEndDrawerMap(ref, homeViewModel.scaffoldKey, isDarkMode)
                            : null,
        appBar: AtomAppBarWithSearch(
          title: homeViewModel.configApp.configuration?.titleApp ?? 'Accueil',
          searchHint: 'Recherche...',
          isDarkMode: isDarkMode,
          searchController: (goRouter.state.name ?? '') == Paths.articleXml
              ? ref.read(articlesXmlProvider).searchController
              : (goRouter.state.name ?? '') == Paths.directoryXml
                  ? ref.read(directoriesXmlProvider).searchController
                  : (goRouter.state.name ?? '') == Paths.eventsXml
                      ? ref.read(eventsXmlProvider).searchController
                      : (goRouter.state.name ?? '') == Paths.directoryXml
                          ? ref.read(publicationsXmlProvider).searchController
                          : homeViewModel.searchController,
          onSearchChanged: (text) => homeViewModel.onSearchTextChanged(ref, text),
          onSearchCleared: () => homeViewModel.clearSearch(ref),
          backgroundColor: Theme.of(context).primaryColor,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => homeViewModel.scaffoldKey.currentState?.openDrawer(),
              child: const Icon(
                Icons.menu,
                size: 24,
              ),
            ),
          ),
          actions: [
            NotificationIconBadge(
              iconData: Icons.notifications_none_sharp,
              onTap: () => NavigationService.push(context, ref,Paths.notifications),
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
        body: RefreshIndicator(
          color: isDarkMode ? primaryDark : primaryLight,
          onRefresh: () async {
            if ((goRouter.state.path ?? '') == Paths.contentHome) {
              ref.read(contentHomeViewModel.currentIndexCarousel.notifier).state.clear();
              contentHomeViewModel.clearSearch(ref);
              try {
                homeViewModel.resetNotificationCountInitialization();
                _isInitialized = false;

                contentHomeViewModel.statusConnection = null;
                ref.watch(notificationsProvider).statusConnectionNotification = null;
                ref.watch(notificationsProvider).statusConnectionThematic = null;
                homeViewModel.statusConnectionMenu = null;
                homeViewModel.statusConnectionTabBar = null;
                await Future.wait([
                  ref.read(tileViewModelStateNotifierProvider.notifier).refreshFromServer(),
                  ref.read(buildPageViewModelStateNotifierProvider.notifier).refreshFromServer(),
                  ref.read(menuViewModelStateNotifierProvider.notifier).refreshFromServer(),
                  ref.read(tabBarViewModelStateNotifierProvider.notifier).refreshFromServer(),
                  ref.read(notificationViewModelStateNotifierProvider.notifier).refreshFromServer(),
                  ref.read(thematicViewModelStateNotifierProvider.notifier).refreshFromServer(),
                ]);
                await _initializeNotificationCount();
              } catch (e) {
                debugPrint('Erreur lors du refresh: $e');
              }
            }
          },
          child: ref.watch(buildPageListProvider).maybeMap(
                orElse: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCA542B))),
                success: (buildPageData) {
                  buildPageData.data.fold((l) => Container(), (buildPage) {
                    contentHomeViewModel.initialiseContentHome(ref, buildPage);
                  });
                  return ref.watch(menuListProvider).maybeMap(
                        orElse: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCA542B))),
                        success: (menu) {
                          menu.data.fold((l) => Container(), (data) async {
                            homeViewModel.initialiseMenu(ref, data);
                          });
                          return ref.watch(tabBarListProvider).maybeMap(
                                orElse: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCA542B))),
                                success: (tabBar) {
                                  tabBar.data.fold((l) => Container(), (data) async {
                                    homeViewModel.initialiseTabBar(ref, data);
                                  });

                                  if (!_isInitialized) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _initializeNotificationCount();
                                    });
                                  }

                                  return widget.child ?? const SizedBox();
                                },
                                error: (error) => AtomErrorConnexion(
                                  onTap: () {
                                    ref.read(tabBarViewModelStateNotifierProvider.notifier).getTabBarProjectFromLocal();
                                  },
                                ),
                              );
                        },
                        error: (error) => AtomErrorConnexion(
                          onTap: () {
                            ref.read(menuViewModelStateNotifierProvider.notifier).getMenuProjectFromLocal();
                          },
                        ),
                      );
                },
                error: (error) => AtomErrorConnexion(
                  onTap: () {
                    ref.read(buildPageViewModelStateNotifierProvider.notifier).getPageHomeFromLocal();
                  },
                ),
              ),
        ),
        bottomNavigationBar: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            AtomItemBottomNavigationBar(
              text: 'Accueil',
              index: 0,
              currentIndex: ref.watch(homeViewModel.currentIndex),
              iconData: Icons.home_outlined,
              onTap: () async {
                for (int i = 0; i < ref.read(ref.read(contentHomeProvider).currentIndexCarousel).length; i++) {
                  ref.read(contentHomeProvider).changeCurrentIndexCarousel(i, 0, ref);
                }
                ref.read(homeViewModel.currentIndex.notifier).state = 0;
                homeViewModel.lastIndex = 0;
                NavigationService.go(context, ref,Paths.contentHome);
              },
            ),
            AtomItemBottomNavigationBar(
              text: 'Favoris',
              index: 1,
              currentIndex: ref.watch(homeViewModel.currentIndex),
              iconData: Icons.star_border,
              onTap: () async {
                ref.read(homeViewModel.currentIndex.notifier).state = 1;
                homeViewModel.lastIndex = 1;
                NavigationService.go(context, ref, Paths.favorites);
              },
            ),
            for (int index = 0; index < ref.watch(homeViewModel.tabBarList).length; index++)
              if (index < 2 && ref.watch(homeViewModel.tabBarList).length == 4 || ref.watch(homeViewModel.tabBarList).length < 4)
                Consumer(
                  builder: (context, ref, widget) {
                    final homeViewModel = ref.watch(homeProvider);
                    final tabBar = ref.watch(homeViewModel.tabBarList)[index];
                    final iconData = tabBar.icon == null ? null : int.parse(tabBar.icon!);
                    return AtomItemBottomNavigationBar(
                      text: tabBar.titleTabBar ?? '',
                      index: index + 2,
                      isImage: tabBar.pictoImg?.localPath != null || tabBar.pictoImg?.url != null,
                      base64ImageData: tabBar.pictoImg?.url,
                      labelImage: tabBar.pictoImg?.filename,
                      localImagePath: tabBar.pictoImg?.localPath,
                      currentIndex: ref.watch(homeViewModel.currentIndex),
                      isActive: tabBar.publicTabBar ?? false,
                      iconData: iconData == null ? null : listPicto[iconData].icon,
                      onTap: () async {
                        ref.read(homeViewModel.currentIndex.notifier).state = index + 2;
                        homeViewModel.lastIndex = index + 2;
                        await context.redirectToTile(ref, tabBar.tile ?? '', false);
                      },
                    );
                  },
                ),
            if (ref.watch(homeViewModel.tabBarList).length == 4)
              CompositedTransformTarget(
                link: homeViewModel.layerLink,
                child: AtomItemBottomNavigationBar(
                  text: 'Plus',
                  index: 4,
                  currentIndex: ref.watch(homeViewModel.currentIndex),
                  iconData: ref.watch(homeViewModel.currentIndex) == 4 ? Icons.close : Icons.more_horiz_outlined,
                  onTap: () async {
                    ref.read(homeViewModel.currentIndex.notifier).state = 4;
                    homeViewModel.showOverlay(context, ref);
                  },
                ),
              )
            else
              for (int index = 0; index < (5 - ref.watch(homeViewModel.tabBarList).length - 2); index++)
                const AtomItemBottomNavigationBar(
                  text: '',
                  index: -1,
                  currentIndex: -2,
                ),
          ],
        ),
      ),
    );
  }
}
