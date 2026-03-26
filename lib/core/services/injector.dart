import 'package:get_it/get_it.dart';

import '../../features/favorites/domain/modals/favorite.dart';
import '../../features/home/domain/modals/content_home/build_page.dart';
import '../../features/home/domain/modals/content_home/carrousel.dart';
import '../../features/home/domain/modals/content_home/event.dart';
import '../../features/home/domain/modals/content_home/flux.dart';
import '../../features/home/domain/modals/content_home/flux_xml_rss_channel.dart';
import '../../features/home/domain/modals/content_home/flux_xml_rss_item.dart';
import '../../features/home/domain/modals/content_home/news.dart';
import '../../features/home/domain/modals/content_home/publication.dart';
import '../../features/home/domain/modals/content_home/quick_access.dart';
import '../../features/home/domain/modals/content_home/repeater.dart';
import '../../features/home/domain/modals/content_home/row.dart';
import '../../features/home/domain/modals/content_home/section.dart';
import '../../features/home/domain/modals/menu/menu.dart';
import '../../features/home/domain/modals/tab_bar/tab_bar.dart';
import '../../features/notifications/domain/modals/notification/notification.dart';
import '../../features/notifications/domain/modals/thematic/thematic.dart';
import '../../features/preloader/domain/modals/config_app.dart';
import '../../features/preloader/domain/modals/configuration.dart';
import '../../features/publicity/domain/modals/publicity.dart';
import '../../features/tile/domain/modals/pictogram.dart';
import '../../features/tile/domain/modals/tile.dart';
import '../../features/tile/domain/modals/tile_content.dart';
import '../../features/map/domain/modals/tile_map.dart';
import '../../features/tile/domain/modals/tile_quick_access.dart';
import '../../features/tile/domain/modals/tile_url.dart';
import '../../features/tile/domain/modals/tile_xml.dart';
import '../../features/tile/domain/modals/type_tile.dart';
import '../memory/local_storage_list_service.dart';
import '../memory/local_storage_service.dart';
import 'feed/domain/modals/feed.dart';
import 'image_app/modals/image_app.dart';
import 'term/domain/modals/term.dart';

final GetIt getIt = GetIt.instance;

Future<void> initSingletons() async {
  getIt.registerLazySingleton<LocalStorageService<ConfigApp>>(
    () => LocalStorageService<ConfigApp>('configApp'),
  );
  getIt.registerLazySingleton<LocalStorageService<Configuration>>(
    () => LocalStorageService<Configuration>('configuration'),
  );

  getIt.registerLazySingleton<LocalStorageService<Publicity>>(
    () => LocalStorageService<Publicity>('publicity'),
  );
  getIt.registerLazySingleton<LocalStorageService<ImageApp>>(
    () => LocalStorageService<ImageApp>('imageApp'),
  );

  getIt.registerLazySingleton<LocalStorageService<BuildPage>>(
    () => LocalStorageService<BuildPage>('buildPage'),
  );
  getIt.registerLazySingleton<LocalStorageService<Section>>(
        () => LocalStorageService<Section>('section'),
  );
  getIt.registerLazySingleton<LocalStorageService<Carrousel>>(
    () => LocalStorageService<Carrousel>('carrousel'),
  );
  getIt.registerLazySingleton<LocalStorageService<Event>>(
    () => LocalStorageService<Event>('event'),
  );
  getIt.registerLazySingleton<LocalStorageService<Flux>>(
    () => LocalStorageService<Flux>('flux'),
  );
  getIt.registerLazySingleton<LocalStorageService<News>>(
    () => LocalStorageService<News>('news'),
  );
  getIt.registerLazySingleton<LocalStorageService<Publication>>(
    () => LocalStorageService<Publication>('publication'),
  );
  getIt.registerLazySingleton<LocalStorageService<QuickAccess>>(
    () => LocalStorageService<QuickAccess>('quickAccess'),
  );
  getIt.registerLazySingleton<LocalStorageService<Repeater>>(
    () => LocalStorageService<Repeater>('repeater'),
  );
  getIt.registerLazySingleton<LocalStorageService<Row>>(
    () => LocalStorageService<Row>('row'),
  );

  getIt.registerLazySingleton<LocalStorageListService<TabBar>>(
    () => LocalStorageListService<TabBar>(
      boxName: 'tabBars',
      fromJsonFactory: (json) => TabBar.fromJson(json),
      toJsonFactory: (tabBar) => tabBar.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageListService<Menu>>(
    () => LocalStorageListService<Menu>(
      boxName: 'menu',
      fromJsonFactory: (json) => Menu.fromJson(json),
      toJsonFactory: (menu) => menu.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageListService<Notification>>(
    () => LocalStorageListService<Notification>(
      boxName: 'notification',
      fromJsonFactory: (json) => Notification.fromJson(json),
      toJsonFactory: (notification) => notification.toJson(),
    ),
  );

  getIt.registerLazySingleton<LocalStorageListService<Thematic>>(
    () => LocalStorageListService<Thematic>(
      boxName: 'thematic',
      fromJsonFactory: (json) => Thematic.fromJson(json),
      toJsonFactory: (thematic) => thematic.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageListService<Tile>>(
    () => LocalStorageListService<Tile>(
      boxName: 'tile',
      fromJsonFactory: (json) => Tile.fromJson(json),
      toJsonFactory: (tile) => tile.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageListService<TypeTile>>(
    () => LocalStorageListService<TypeTile>(
      boxName: 'typeTile',
      fromJsonFactory: (json) => TypeTile.fromJson(json),
      toJsonFactory: (typeTile) => typeTile.toJson(),
    ),
  );

  getIt.registerLazySingleton<LocalStorageListService<Feed>>(
    () => LocalStorageListService<Feed>(
      boxName: 'feed',
      fromJsonFactory: (json) => Feed.fromJson(json),
      toJsonFactory: (feed) => feed.toJson(),
    ),
  );

  getIt.registerLazySingleton<LocalStorageListService<Term>>(
    () => LocalStorageListService<Term>(
      boxName: 'term',
      fromJsonFactory: (json) => Term.fromJson(json),
      toJsonFactory: (term) => term.toJson(),
    ),
  );

  getIt.registerLazySingleton<LocalStorageService<TileContent>>(
    () => LocalStorageService<TileContent>('tileContent'),
  );
  getIt.registerLazySingleton<LocalStorageService<TileContentResults>>(
    () => LocalStorageService<TileContentResults>('tileContentResults'),
  );

  getIt.registerLazySingleton<LocalStorageService<TileMap>>(
    () => LocalStorageService<TileMap>('tileMap'),
  );
  getIt.registerLazySingleton<LocalStorageService<TileMapResults>>(
    () => LocalStorageService<TileMapResults>('tileMapResults'),
  );

  getIt.registerLazySingleton<LocalStorageListService<TileMapId>>(
    () => LocalStorageListService<TileMapId>(
      boxName: 'tileMapId',
      fromJsonFactory: (json) => TileMapId.fromJson(json),
      toJsonFactory: (tileMapId) => tileMapId.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageService<TileQuickAccess>>(
    () => LocalStorageService<TileQuickAccess>('tileQuickAccess'),
  );
  getIt.registerLazySingleton<LocalStorageService<TileQuickAccessResults>>(
    () => LocalStorageService<TileQuickAccessResults>('tileQuickAccessResults'),
  );
  getIt.registerLazySingleton<LocalStorageListService<QuickAccessData>>(
    () => LocalStorageListService<QuickAccessData>(
      boxName: 'quickAccessData',
      fromJsonFactory: (json) => QuickAccessData.fromJson(json),
      toJsonFactory: (quickAccessData) => quickAccessData.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageListService<Pictogram>>(
    () => LocalStorageListService<Pictogram>(
      boxName: 'pictogram',
      fromJsonFactory: (json) => Pictogram.fromJson(json),
      toJsonFactory: (pictogram) => pictogram.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageService<TileUrl>>(
    () => LocalStorageService<TileUrl>('tileUrl'),
  );
  getIt.registerLazySingleton<LocalStorageService<TileUrlResults>>(
    () => LocalStorageService<TileUrlResults>('tileUrlResults'),
  );
  getIt.registerLazySingleton<LocalStorageService<TileXml>>(
    () => LocalStorageService<TileXml>('tileXml'),
  );
  getIt.registerLazySingleton<LocalStorageService<TileXmlResults>>(
    () => LocalStorageService<TileXmlResults>('tileXmlResults'),
  );
  getIt.registerLazySingleton<LocalStorageListService<TileXmlId>>(
    () => LocalStorageListService<TileXmlId>(
      boxName: 'tileXmlId',
      fromJsonFactory: (json) => TileXmlId.fromJson(json),
      toJsonFactory: (tileXmlId) => tileXmlId.toJson(),
    ),
  );
  getIt.registerLazySingleton<LocalStorageListService<Favorite>>(
    () => LocalStorageListService<Favorite>(
      boxName: 'favorite',
      fromJsonFactory: (json) => Favorite.fromJson(json),
      toJsonFactory: (favorite) => favorite.toJson(),
    ),
  );

  getIt.registerLazySingleton<LocalStorageService<FluxXmlRSSChannel>>(
        () => LocalStorageService<FluxXmlRSSChannel>('fluxXmlRSSChannel'),
  );

  getIt.registerLazySingleton<LocalStorageListService<FluxXmlRSSItem>>(
        () => LocalStorageListService<FluxXmlRSSItem>(
      boxName: 'fluxXmlRSSItem',
      fromJsonFactory: (json) => FluxXmlRSSItem.fromJson(json),
      toJsonFactory: (favorite) => favorite.toMap(),
    ),
  );

  await _initializeServices();
}

Future<void> _initializeServices() async {
  await getIt<LocalStorageService<ConfigApp>>().initialize();
  await getIt<LocalStorageService<Configuration>>().initialize();
  await getIt<LocalStorageService<Publicity>>().initialize();
  await getIt<LocalStorageService<ImageApp>>().initialize();
  await getIt<LocalStorageService<BuildPage>>().initialize();
  await getIt<LocalStorageService<Carrousel>>().initialize();
  await getIt<LocalStorageService<Section>>().initialize();
  await getIt<LocalStorageService<Event>>().initialize();
  await getIt<LocalStorageService<Flux>>().initialize();
  await getIt<LocalStorageService<News>>().initialize();
  await getIt<LocalStorageService<Publication>>().initialize();
  await getIt<LocalStorageService<QuickAccess>>().initialize();
  await getIt<LocalStorageService<Repeater>>().initialize();
  await getIt<LocalStorageService<Row>>().initialize();
  await getIt<LocalStorageListService<TabBar>>().initialize();
  await getIt<LocalStorageListService<Menu>>().initialize();
  await getIt<LocalStorageListService<Notification>>().initialize();
  await getIt<LocalStorageListService<Thematic>>().initialize();
  await getIt<LocalStorageListService<Tile>>().initialize();
  await getIt<LocalStorageListService<TypeTile>>().initialize();
  await getIt<LocalStorageListService<Feed>>().initialize();
  await getIt<LocalStorageListService<Term>>().initialize();
  await getIt<LocalStorageService<TileContent>>().initialize();
  await getIt<LocalStorageService<TileContentResults>>().initialize();
  await getIt<LocalStorageService<TileMap>>().initialize();
  await getIt<LocalStorageService<TileMapResults>>().initialize();
  await getIt<LocalStorageListService<TileMapId>>().initialize();
  await getIt<LocalStorageService<TileQuickAccess>>().initialize();
  await getIt<LocalStorageService<TileQuickAccessResults>>().initialize();
  await getIt<LocalStorageListService<QuickAccessData>>().initialize();
  await getIt<LocalStorageListService<Pictogram>>().initialize();
  await getIt<LocalStorageService<TileUrl>>().initialize();
  await getIt<LocalStorageService<TileUrlResults>>().initialize();
  await getIt<LocalStorageService<TileXml>>().initialize();
  await getIt<LocalStorageService<TileXmlResults>>().initialize();
  await getIt<LocalStorageListService<TileXmlId>>().initialize();
  await getIt<LocalStorageListService<Favorite>>().initialize();
  await getIt<LocalStorageService<FluxXmlRSSChannel>>().initialize();
  await getIt<LocalStorageListService<FluxXmlRSSItem>>().initialize();
}
