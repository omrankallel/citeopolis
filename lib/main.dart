import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';

import '../../l10n/app_localizations.dart';
import 'core/core.dart';
import 'core/network/connectivity_wrapper.dart';
import 'core/services/feed/domain/modals/feed.dart';
import 'core/services/image_app/modals/image_app.dart';
import 'core/services/injector.dart';
import 'core/services/notification_service.dart';
import 'core/services/term/domain/modals/term.dart';
import 'design_system/atoms/atom_status.dart';
import 'features/favorites/domain/modals/favorite.dart';
import 'features/home/domain/modals/content_home/build_page.dart';
import 'features/home/domain/modals/content_home/carrousel.dart';
import 'features/home/domain/modals/content_home/event.dart';
import 'features/home/domain/modals/content_home/flux.dart';
import 'features/home/domain/modals/content_home/flux_xml_rss_channel.dart';
import 'features/home/domain/modals/content_home/flux_xml_rss_item.dart';
import 'features/home/domain/modals/content_home/news.dart';
import 'features/home/domain/modals/content_home/publication.dart';
import 'features/home/domain/modals/content_home/quick_access.dart';
import 'features/home/domain/modals/content_home/repeater.dart';
import 'features/home/domain/modals/content_home/row.dart';
import 'features/home/domain/modals/content_home/section.dart';
import 'features/home/domain/modals/menu/menu.dart';
import 'features/home/domain/modals/tab_bar/tab_bar.dart';
import 'features/map/domain/modals/tile_map.dart';
import 'features/notifications/domain/modals/notification/notification.dart';
import 'features/notifications/domain/modals/thematic/thematic.dart';
import 'features/preloader/domain/modals/config_app.dart';
import 'features/preloader/domain/modals/configuration.dart';
import 'features/publicity/domain/modals/publicity.dart';
import 'features/tile/domain/modals/pictogram.dart';
import 'features/tile/domain/modals/tile.dart';
import 'features/tile/domain/modals/tile_content.dart';
import 'features/tile/domain/modals/tile_quick_access.dart';
import 'features/tile/domain/modals/tile_url.dart';
import 'features/tile/domain/modals/tile_xml.dart';
import 'features/tile/domain/modals/type_tile.dart';
import 'router/routes.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Message reçu en arrière-plan: ${message.messageId}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      debugPrint('Notification cliquée: ${details.payload}');
    },
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase déjà initialisé : $e');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeLocalNotifications();
  await NotificationService.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(ConfigAppAdapter());
  Hive.registerAdapter(ConfigurationAdapter());
  Hive.registerAdapter(PublicityAdapter());
  Hive.registerAdapter(ImageAppAdapter());
  Hive.registerAdapter(BuildPageAdapter());
  Hive.registerAdapter(SectionAdapter());
  Hive.registerAdapter(CarrouselAdapter());
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(FluxAdapter());
  Hive.registerAdapter(NewsAdapter());
  Hive.registerAdapter(PublicationAdapter());
  Hive.registerAdapter(QuickAccessAdapter());
  Hive.registerAdapter(RepeaterAdapter());
  Hive.registerAdapter(RowAdapter());
  Hive.registerAdapter(TabBarAdapter());
  Hive.registerAdapter(MenuAdapter());
  Hive.registerAdapter(NotificationAdapter());
  Hive.registerAdapter(ThematicAdapter());
  Hive.registerAdapter(TileAdapter());
  Hive.registerAdapter(TypeTileAdapter());
  Hive.registerAdapter(FeedAdapter());
  Hive.registerAdapter(TermAdapter());
  Hive.registerAdapter(TileContentAdapter());
  Hive.registerAdapter(TileContentResultsAdapter());
  Hive.registerAdapter(TileMapAdapter());
  Hive.registerAdapter(TileMapResultsAdapter());
  Hive.registerAdapter(TileMapIdAdapter());
  Hive.registerAdapter(TileQuickAccessAdapter());
  Hive.registerAdapter(TileQuickAccessResultsAdapter());
  Hive.registerAdapter(QuickAccessDataAdapter());
  Hive.registerAdapter(PictogramAdapter());
  Hive.registerAdapter(TileUrlAdapter());
  Hive.registerAdapter(TileUrlResultsAdapter());
  Hive.registerAdapter(TileXmlAdapter());
  Hive.registerAdapter(TileXmlResultsAdapter());
  Hive.registerAdapter(TileXmlIdAdapter());
  Hive.registerAdapter(FavoriteAdapter());
  Hive.registerAdapter(FluxXmlRSSChannelAdapter());
  Hive.registerAdapter(FluxXmlRSSItemAdapter());
  await initSingletons();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeViewModel = ref.watch(themeProvider);
    final themeMode = themeViewModel.themeMode;
    final appLocal = ref.watch(localizationsService).appLocal;

    return OKToast(
      child: ConnectivityWrapper(
        child: MaterialApp.router(
          routerDelegate: goRouter.routerDelegate,
          routeInformationParser: goRouter.routeInformationParser,
          routeInformationProvider: goRouter.routeInformationProvider,
          title: 'Citeopolis',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            String? currentPath;
            try {
              currentPath = goRouter.state.path;
            } catch (e) {
              currentPath = null;
            }
            final isPreloaderPage = currentPath == Paths.preloader;
            return isPreloaderPage
                ? child ?? const SizedBox()
                : Stack(
                    children: [
                      child!,
                      Positioned(
                        top: 100,
                        left: 10,
                        child: Consumer(
                          builder: (context, ref, _) => const AtomStatus(),
                        ),
                      ),
                    ],
                  );
          },
          themeMode: themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          locale: appLocal,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fr', 'FR'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
