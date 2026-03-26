import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/tile_extension.dart';
import '../../../../core/memory/local_storage_service.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/injector.dart';
import '../../../../core/utils/icon_picto_helper.dart';
import '../../../../design_system/atoms/atom_text.dart';
import '../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../router/routes.dart';
import '../../../content_home/presentation/viewmodel/content_home_view_model.dart';
import '../../../map/presentation/viewmodel/map_view_model.dart';
import '../../../notifications/data/repositories/notification/notification_data_module.dart';
import '../../../notifications/presentation/viewmodel/notifications_view_model.dart';
import '../../../preloader/domain/modals/config_app.dart';
import '../../../tile/presentation/viewmodel/quick_access/quick_access_tile_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/article/articles_xml_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/directory/directories_xml_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/event/events_xml_view_model.dart';
import '../../../tile/presentation/viewmodel/xml/publication/publications_xml_view_model.dart';
import '../../domain/modals/menu/menu.dart';
import '../../domain/modals/tab_bar/tab_bar.dart' as tab_bar;
import '../view/widget/build_widget_animated_overlay.dart';

final homeProvider = ChangeNotifierProvider((ref) => HomeProvider());

class HomeProvider extends ChangeNotifier {
  final LocalStorageService<ConfigApp> preloaderStorage = getIt<LocalStorageService<ConfigApp>>();
  ConfigApp configApp = ConfigApp();

  Future<void> initializeConfigApp(WidgetRef ref) async {
    try {
      final projectId = ProdConfig().projectId;
      final config = preloaderStorage.get(projectId);
      if (config != null) {
        configApp = config;
        debugPrint('Configuration du projet initialisée: ${config.toJson()}');
      } else {
        debugPrint('Aucune configuration trouvée pour le projet $projectId');
      }
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation de la configuration du projet: $e");
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();
  final searchText = StateProvider<String>((ref) => '');

  final isPopupOpen = StateProvider<bool>((ref) => false);

  final currentIndex = StateProvider<int>((ref) => 0);
  int lastIndex = 0;

  final groupValueLanguage = StateProvider<int>((ref) => 1);

  bool _hasInitializedNotificationCount = false;

  Future<void> initializeNotificationCount(WidgetRef ref) async {
    if (_hasInitializedNotificationCount) return;

    try {
      final projectId = int.parse(ProdConfig().projectId);
      final repository = ref.read(notificationRepositoryProvider);
      final result = await repository.getUnreadNotificationsCount(projectId);

      result.fold(
        (error) => debugPrint("Erreur lors de l'initialisation du compteur: $error"),
        (count) {
          ref.read(unreadCountStateProvider.notifier).state = count;
          debugPrint('Compteur de notifications initialisé: $count');
        },
      );

      _hasInitializedNotificationCount = true;
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation du compteur: $e");
    }
  }

  void resetNotificationCountInitialization() {
    _hasInitializedNotificationCount = false;
  }




  Future<void> showDialogLanguage(BuildContext context, WidgetRef ref) async {
    final String languageCode = ref.read(localizationsService).appLocal.languageCode;
    switch (languageCode) {
      case 'fr':
        ref.read(groupValueLanguage.notifier).state = 1;
        break;
      case 'en':
        ref.read(groupValueLanguage.notifier).state = 2;
        break;
      case 'de':
        ref.read(groupValueLanguage.notifier).state = 3;
        break;
    }
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
        ),
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: AtomText(
              data: 'Annuler',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  ),
            ),
          ),
          16.pw,
          InkWell(
            onTap: () {
              switch (ref.read(groupValueLanguage)) {
                case 1:
                  ref.read(localizationsService).changeLanguage(const Locale('fr'));
                  break;
                case 2:
                  ref.read(localizationsService).changeLanguage(const Locale('en'));
                  break;
                case 3:
                  ref.read(localizationsService).changeLanguage(const Locale('de'));
                  break;
              }
              Navigator.pop(context);
            },
            child: AtomText(
              data: 'Ok',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  ),
            ),
          ),
        ],
        content: Consumer(
          builder: (context, ref, widget) => SizedBox(
            width: Helpers.getResponsiveWidth(context) * .5,
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtomText(
                  data: 'Choisir une langue',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                20.ph,
                ListTile(
                  onTap: () => ref.read(groupValueLanguage.notifier).state = 1,
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: RadioGroup<int>(
                      groupValue: ref.watch(groupValueLanguage),
                      onChanged: (value) => ref.read(groupValueLanguage.notifier).state = 1,
                      child: const Radio<int>(
                        value: 1,
                      ),
                    ),
                  ),
                  title: AtomText(
                    data: 'Français (FR)',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
                ListTile(
                  onTap: () => ref.read(groupValueLanguage.notifier).state = 2,
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: RadioGroup<int>(
                      groupValue: ref.watch(groupValueLanguage),
                      onChanged: (value) => ref.read(groupValueLanguage.notifier).state = 2,
                      child: const Radio<int>(
                        value: 2,
                      ),
                    ),
                  ),
                  title: AtomText(
                    data: 'English (EN)',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
                ListTile(
                  onTap: () => ref.read(groupValueLanguage.notifier).state = 3,
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: RadioGroup<int>(
                      groupValue: ref.watch(groupValueLanguage),
                      onChanged: (value) => ref.read(groupValueLanguage.notifier).state = 3,
                      child: const Radio<int>(
                        value: 3,
                      ),
                    ),
                  ),
                  title: AtomText(
                    data: 'Deutsch (DE)',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  bool? statusConnectionMenu;
  final menuList = StateProvider<List<Menu>>((ref) => []);

  bool? statusConnectionTabBar;
  final tabBarList = StateProvider<List<tab_bar.TabBar>>((ref) => []);

  void initialiseMenu(WidgetRef ref, List<Menu> list) {
    final isConnected = ref.watch(isConnectedProvider);
    if (list.isNotEmpty && isConnected != statusConnectionMenu) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(menuList.notifier).state.clear();
        ref.read(menuList.notifier).state = List<Menu>.from(list.map((item) => item.copyWith()));
        statusConnectionMenu = isConnected;
      });
    }
  }

  void initialiseTabBar(WidgetRef ref, List<tab_bar.TabBar> list) {
    final isConnected = ref.watch(isConnectedProvider);
    if (list.isNotEmpty && isConnected != statusConnectionTabBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(tabBarList.notifier).state.clear();
        ref.read(tabBarList.notifier).state = list.where((element) => element.publicTabBar ?? false).toList();
        statusConnectionTabBar = isConnected;
      });
    }
  }

  void onSearchTextChanged(WidgetRef ref, String query) {
    final route = goRouter.state.name ?? '';
    if (route == Paths.contentHome) {
      ref.watch(contentHomeProvider).onSearchTextChanged(ref, query);
    } else if (route == Paths.carte) {
      ref.watch(mapProvider).onSearchTextChanged(ref, query);
    } else if (route == Paths.articleXml) {
      ref.watch(articlesXmlProvider).onSearchTextChanged(ref, query);
    } else if (route == Paths.eventsXml) {
      ref.watch(eventsXmlProvider).onSearchTextChanged(ref, query);
    } else if (route == Paths.directoryXml) {
      ref.watch(directoriesXmlProvider).onSearchTextChanged(ref, query);
    } else if (route == Paths.publicationXml) {
      ref.watch(publicationsXmlProvider).onSearchTextChanged(ref, query);
    } else if (route == Paths.quickAccess) {
      ref.watch(quickAccessTileProvider).onSearchTextChanged(ref, query);
    }
  }

  void clearSearch(WidgetRef ref) {
    final route = goRouter.state.name ?? '';
    searchController.clear();
    if (route == Paths.contentHome) {
      ref.watch(contentHomeProvider).clearSearch(ref);
    } else if (route == Paths.carte) {
      ref.watch(mapProvider).onSearchTextChanged(ref, '');
    } else if (route == Paths.articleXml) {
      ref.watch(articlesXmlProvider).onSearchTextChanged(ref, '');
    } else if (route == Paths.eventsXml) {
      ref.watch(eventsXmlProvider).onSearchTextChanged(ref, '');
    } else if (route == Paths.directoryXml) {
      ref.watch(directoriesXmlProvider).onSearchTextChanged(ref, '');
    } else if (route == Paths.publicationXml) {
      ref.watch(publicationsXmlProvider).onSearchTextChanged(ref, '');
    } else if (route == Paths.quickAccess) {
      ref.watch(quickAccessTileProvider).clearSearch(ref);
    }
  }

  Future<void> launchSocialUrl(String url) async {
    scaffoldKey.currentState?.closeDrawer();
    await Future.delayed(const Duration(milliseconds: 300));

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      debugPrint('Could not launch $url');
    }
  }

  OverlayEntry? entry;
  final LayerLink layerLink = LayerLink();
  AnimationController? animationController;

  void showOverlay(BuildContext context, WidgetRef ref) {
    final overlay = Overlay.of(context);
    final navigator = Navigator.of(context);

    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: navigator,
    );

    entry = OverlayEntry(
      builder: (context) => WidgetAnimatedOverlay(
        animationController: animationController!,
        layerLink: layerLink,
        onDismiss: () => hideOverlay(ref),
        child: buildOverlay(context, ref),
      ),
    );

    overlay.insert(entry!);

    animationController!.forward();
  }

  Widget buildOverlay(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final tabBarItems = ref.watch(tabBarList);

    final publicItems = tabBarItems.skip(2).where((tabBar) => tabBar.publicTabBar ?? false).toList();

    return Container(
      constraints: BoxConstraints(
        maxWidth: 200,
        maxHeight: screenSize.height * 0.25,
        minHeight: 100,
      ),
      decoration: BoxDecoration(
        color: ref.watch(themeProvider).isDarkMode ? surfaceContainerDark : surfaceContainerLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5.0),
        ),
      ),
      child: publicItems.isEmpty
          ? const SizedBox()
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              itemCount: publicItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final tabBar = publicItems[index];
                return _buildOverlayItem(context, ref, tabBar);
              },
            ),
    );
  }

  Widget _buildOverlayItem(BuildContext context, WidgetRef ref, tab_bar.TabBar tabBar) {
    final iconData = tabBar.icon != null ? int.tryParse(tabBar.icon!) : null;
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final textColor = isDarkMode ? onSurfaceDark : onSurfaceLight;

    return InkWell(
      onTap: () async {
        if (animationController != null) {
          await animationController!.reverse();
        }
        lastIndex = 4;
        hideOverlay(ref);

        if ((tabBar.tile ?? '').isNotEmpty && context.mounted) {
          await context.redirectToTile(ref, tabBar.tile!, false);
        }
      },
      splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: _buildIcon(tabBar, iconData, textColor),
            ),
            10.pw,
            // Titre
            Text(
              tabBar.titleTabBar ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: textColor,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(tab_bar.TabBar tabBar, int? iconData, Color textColor) {
    if (tabBar.pictoImg?.localPath != null || tabBar.pictoImg?.url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AtomUploadImage(
          base64ImageData: tabBar.pictoImg?.url,
          labelImage: tabBar.pictoImg?.filename,
          localImagePath: tabBar.pictoImg?.localPath,
        ),
      );
    }

    if (iconData != null && iconData < listPicto.length) {
      return Icon(
        listPicto[iconData].icon,
        color: textColor,
        size: 24,
      );
    }

    return Icon(
      Icons.apps,
      color: textColor,
      size: 24,
    );
  }

  void hideOverlay(WidgetRef ref) {
    entry?.remove();
    entry = null;
    ref.read(currentIndex.notifier).state = lastIndex;
  }
}
