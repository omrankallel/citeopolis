import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_navigation.dart';
import '../features/blank_page/presentation/blank_page_view.dart';
import '../features/blank_page/presentation/blank_page_view_with_scaffold.dart';
import '../features/content_detail/presentation/view/content_detail_view.dart';
import '../features/content_home/presentation/view/content_home_view.dart';
import '../features/favorites/presentation/view/favorites_view.dart';
import '../features/home/presentation/view/home_view.dart';
import '../features/map/domain/modals/tile_map.dart';
import '../features/map/domain/modals/xml_map.dart';
import '../features/map/presentation/view/detail_map_xml_view.dart';
import '../features/map/presentation/view/map_view.dart';
import '../features/map/presentation/view/map_view_with_scaffold.dart';
import '../features/notifications/presentation/view/notifications_view.dart';
import '../features/preloader/presentation/view/preloader_view.dart';
import '../features/publicity/presentation/view/publicity_view.dart';
import '../features/settings/presentation/view/settings_view.dart';
import '../features/tile/domain/modals/tile_content.dart';
import '../features/tile/domain/modals/tile_quick_access.dart';
import '../features/tile/domain/modals/tile_xml.dart';
import '../features/tile/domain/modals/xml/xml_article.dart';
import '../features/tile/domain/modals/xml/xml_directory.dart';
import '../features/tile/domain/modals/xml/xml_event.dart';
import '../features/tile/domain/modals/xml/xml_publication.dart';
import '../features/tile/presentation/view/content/content_tile_view.dart';
import '../features/tile/presentation/view/content/content_tile_view_with_scaffold.dart';
import '../features/tile/presentation/view/quick_access/quick_access_tile_view.dart';
import '../features/tile/presentation/view/quick_access/quick_access_tile_view_with_scaffold.dart';
import '../features/tile/presentation/view/url/url_tile_view.dart';
import '../features/tile/presentation/view/url/url_tile_view_with_scaffold.dart';
import '../features/tile/presentation/view/xml/article/article_xml_view.dart';
import '../features/tile/presentation/view/xml/article/article_xml_view_with_scaffold.dart';
import '../features/tile/presentation/view/xml/article/detail_article_xml_view.dart';
import '../features/tile/presentation/view/xml/directory/detail_directory_xml_view.dart';
import '../features/tile/presentation/view/xml/directory/directory_xml_view.dart';
import '../features/tile/presentation/view/xml/directory/directory_xml_view_with_scaffold.dart';
import '../features/tile/presentation/view/xml/event/detail_event_xml_view.dart';
import '../features/tile/presentation/view/xml/event/event_xml_view.dart';
import '../features/tile/presentation/view/xml/event/event_xml_view_with_scaffold.dart';
import '../features/tile/presentation/view/xml/publication/detail_publication_xml_view.dart';
import '../features/tile/presentation/view/xml/publication/publication_xml_view.dart';
import '../features/tile/presentation/view/xml/publication/publication_xml_view_with_scaffold.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: Paths.preloader,
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => HomeView(
        child: child,
      ),
      routes: [
        GoRoute(
          path: Paths.contentHome,
          name: Paths.contentHome,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ContentHomeView(),
          ),
        ),
        GoRoute(
          path: Paths.carte,
          name: Paths.carte,
          pageBuilder: (context, state) {
            final tileMap = state.extra as TileMap;
            return NoTransitionPage(
              key: state.pageKey,
              child: MapView(tileMap: tileMap),
            );
          },
        ),
        GoRoute(
          path: Paths.articleXml,
          name: Paths.articleXml,
          pageBuilder: (context, state) {
            final tileXml = state.extra as TileXml;
            return NoTransitionPage(
              key: state.pageKey,
              child: ArticleXmlView(tileXml: tileXml),
            );
          },
        ),
        GoRoute(
          path: Paths.eventsXml,
          name: Paths.eventsXml,
          pageBuilder: (context, state) {
            final tileXml = state.extra as TileXml;
            return NoTransitionPage(
              key: state.pageKey,
              child: EventsXmlView(tileXml: tileXml),
            );
          },
        ),
        GoRoute(
          path: Paths.directoryXml,
          name: Paths.directoryXml,
          pageBuilder: (context, state) {
            final tileXml = state.extra as TileXml;
            return NoTransitionPage(
              key: state.pageKey,
              child: DirectoryXmlView(tileXml: tileXml),
            );
          },
        ),
        GoRoute(
          path: Paths.publicationXml,
          name: Paths.publicationXml,
          pageBuilder: (context, state) {
            final tileXml = state.extra as TileXml;
            return NoTransitionPage(
              key: state.pageKey,
              child: PublicationXmlView(tileXml: tileXml),
            );
          },
        ),
        GoRoute(
          path: Paths.contentTile,
          name: Paths.contentTile,
          pageBuilder: (context, state) {
            final tileContent = state.extra as TileContent;
            return NoTransitionPage(
              key: state.pageKey,
              child: ContentTileView(tileContent: tileContent),
            );
          },
        ),
        GoRoute(
          path: Paths.urlTile,
          name: Paths.urlTile,
          pageBuilder: (context, state) {
            final url = state.extra as String;
            return NoTransitionPage(
              key: state.pageKey,
              child: UrlTileView(url: url),
            );
          },
        ),
        GoRoute(
          path: Paths.quickAccess,
          name: Paths.quickAccess,
          pageBuilder: (context, state) {
            final tileQuickAccess = state.extra as TileQuickAccess;
            return NoTransitionPage(
              key: state.pageKey,
              child: QuickAccessTileView(tileQuickAccess: tileQuickAccess),
            );
          },
        ),
        GoRoute(
          path: Paths.favorites,
          name: Paths.favorites,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const FavoritesView(),
          ),
        ),
        GoRoute(
          path: Paths.blankPage,
          name: Paths.blankPage,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const BlankPageView(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: Paths.publicity,
      name: Paths.publicity,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PublicityView(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: Paths.preloader,
      name: Paths.preloader,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PreloaderView(),
        transitionDuration: Duration.zero,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: Paths.contentDetail,
      name: Paths.contentDetail,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ContentDetailView(),
      ),
    ),
    GoRoute(
      path: Paths.notifications,
      name: Paths.notifications,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const NotificationsView(),
      ),
    ),
    GoRoute(
      path: Paths.settings,
      name: Paths.settings,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const SettingsView(),
      ),
    ),
    GoRoute(
      path: Paths.articleXmlWithScaffold,
      name: Paths.articleXmlWithScaffold,
      pageBuilder: (context, state) {
        final tileXml = state.extra as TileXml;
        return NoTransitionPage(
          key: state.pageKey,
          child: ArticleXmlViewWithScaffold(tileXml: tileXml),
        );
      },
    ),
    GoRoute(
      path: Paths.detailArticleXml,
      name: Paths.detailArticleXml,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tileXml = extra['tileXml'];
        final article = extra['articleXml'];
        final allArticles = extra['allArticles'] as List<Article>? ?? [];
        return NoTransitionPage(
          key: state.pageKey,
          child: DetailArticleXmlView(
            tileXml: tileXml,
            article: article,
            allArticles: allArticles,
          ),
        );
      },
    ),
    GoRoute(
      path: Paths.eventsXmlWithScaffold,
      name: Paths.eventsXmlWithScaffold,
      pageBuilder: (context, state) {
        final tileXml = state.extra as TileXml;
        return NoTransitionPage(
          key: state.pageKey,
          child: EventsXmlViewWithScaffold(tileXml: tileXml),
        );
      },
    ),
    GoRoute(
      path: Paths.detailEventsXml,
      name: Paths.detailEventsXml,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tileXml = extra['tileXml'];
        final event = extra['eventXml'];
        final allEvents = extra['allEvents'] as List<Event>? ?? [];
        return NoTransitionPage(
          key: state.pageKey,
          child: DetailEventXmlView(
            tileXml: tileXml,
            event: event,
            allEvents: allEvents,
          ),
        );
      },
    ),
    GoRoute(
      path: Paths.directoryXmlWithScaffold,
      name: Paths.directoryXmlWithScaffold,
      pageBuilder: (context, state) {
        final tileXml = state.extra as TileXml;
        return NoTransitionPage(
          key: state.pageKey,
          child: DirectoryXmlViewWithScaffold(tileXml: tileXml),
        );
      },
    ),
    GoRoute(
      path: Paths.detailDirectoryXml,
      name: Paths.detailDirectoryXml,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tileXml = extra['tileXml'];
        final directory = extra['directoryXml'];
        final allDirectories = extra['allDirectories'] as List<Directory>? ?? [];
        return NoTransitionPage(
          key: state.pageKey,
          child: DetailDirectoryXmlView(
            tileXml: tileXml,
            directory: directory,
            allDirectories: allDirectories,
          ),
        );
      },
    ),
    GoRoute(
      path: Paths.publicationXmlWithScaffold,
      name: Paths.publicationXmlWithScaffold,
      pageBuilder: (context, state) {
        final tileXml = state.extra as TileXml;
        return NoTransitionPage(
          key: state.pageKey,
          child: PublicationXmlViewWithScaffold(tileXml: tileXml),
        );
      },
    ),
    GoRoute(
      path: Paths.detailPublicationXml,
      name: Paths.detailPublicationXml,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tileXml = extra['tileXml'];
        final publication = extra['publicationXml'];
        final allPublications = extra['allPublications'] as List<Publication>? ?? [];
        return NoTransitionPage(
          key: state.pageKey,
          child: DetailPublicationXmlView(
            tileXml: tileXml,
            publication: publication,
            allPublications: allPublications,
          ),
        );
      },
    ),
    GoRoute(
      path: Paths.carteWithScaffold,
      name: Paths.carteWithScaffold,
      pageBuilder: (context, state) {
        final tileMap = state.extra as TileMap;
        return NoTransitionPage(
          key: state.pageKey,
          child: MapViewWithScaffold(tileMap: tileMap),
        );
      },
    ),
    GoRoute(
      path: Paths.detailCarte,
      name: Paths.detailCarte,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tileMap = extra['tileMap'];
        final map = extra['map'];
        final allMap = extra['allMap'] as List<MapXml>? ?? [];
        return NoTransitionPage(
          key: state.pageKey,
          child: DetailMapXmlView(
            tileMap: tileMap,
            map: map,
            allMap: allMap,
          ),
        );
      },
    ),
    GoRoute(
      path: Paths.contentTileWithScaffold,
      name: Paths.contentTileWithScaffold,
      pageBuilder: (context, state) {
        final tileContent = state.extra as TileContent;
        return NoTransitionPage(
          key: state.pageKey,
          child: ContentTileViewWithScaffold(tileContent: tileContent),
        );
      },
    ),
    GoRoute(
      path: Paths.urlTileWithScaffold,
      name: Paths.urlTileWithScaffold,
      pageBuilder: (context, state) {
        String url;
        bool isTile;
        if (state.extra is Map<String, dynamic>) {
          final params = state.extra as Map<String, dynamic>;
          url = params['url'] as String;
          isTile = params['isTile'] as bool;
        } else {
          url = state.extra as String;
          isTile = true;
        }
        return NoTransitionPage(
          key: state.pageKey,
          child: UrlTileViewWithScaffold(url: url, isTile: isTile),
        );
      },
    ),
    GoRoute(
      path: Paths.quickAccessWithScaffold,
      name: Paths.quickAccessWithScaffold,
      pageBuilder: (context, state) {
        final tileQuickAccess = state.extra as TileQuickAccess;
        return NoTransitionPage(
          key: state.pageKey,
          child: QuickAccessTileViewWithScaffold(tileQuickAccess: tileQuickAccess),
        );
      },
    ),
    GoRoute(
      path: Paths.blankPageWithScaffold,
      name: Paths.blankPageWithScaffold,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const BlankPageViewWithScaffold(),
      ),
    ),
  ],
);

abstract class Paths {
  Paths._();

  static const contentHome = '/content_home';
  static const carte = '/carte';
  static const carteWithScaffold = '/carte_with_scaffold';
  static const detailCarte = '/detail_carte';
  static const favorites = '/favorites';
  static const notifications = '/notifications';
  static const publicity = '/publicity';
  static const preloader = '/preloader';
  static const contentDetail = '/content_detail';
  static const quickAccess = '/quick_access';
  static const quickAccessWithScaffold = '/quick_access_with_scaffold';
  static const settings = '/settings';
  static const articleXml = '/article_xml';
  static const articleXmlWithScaffold = '/article_xml_with_scaffold';
  static const detailArticleXml = '/detail_article_xml';
  static const eventsXml = '/events_xml';
  static const eventsXmlWithScaffold = '/events_xml_with_scaffold';
  static const detailEventsXml = '/detail_events_xml';
  static const directoryXml = '/directory_xml_with_scaffold';
  static const directoryXmlWithScaffold = '/director_xml_with_scaffold';
  static const detailDirectoryXml = '/detail_directory_xml';
  static const publicationXml = '/publication_xml';
  static const publicationXmlWithScaffold = '/publication_xml_with_scaffold';
  static const detailPublicationXml = '/detail_publication_xml';
  static const contentTile = '/content_tile';
  static const contentTileWithScaffold = '/content_tile_with_scaffold';
  static const urlTile = '/url_tile';
  static const urlTileWithScaffold = '/url_tile_with_scaffold';
  static const blankPage = '/blank_page';
  static const blankPageWithScaffold = '/blank_page_with_scaffold';
}
