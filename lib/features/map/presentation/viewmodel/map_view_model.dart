import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../../../../core/constants/service.dart';
import '../../../../core/core.dart';
import '../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../design_system/atoms/atom_image.dart';
import '../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../router/navigation_service.dart';
import '../../../../router/routes.dart';
import '../../../home/presentation/viewmodel/home_view_model.dart';
import '../../domain/modals/tile_map.dart';
import '../../domain/modals/xml_map.dart';

final mapProvider = ChangeNotifierProvider.autoDispose((ref) => MapProvider());

class MapProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();

  bool isInitialized = false;

  BuildContext? context;
  Map<String, Marker> markers = {};

  final mapController = MapController();

  final selectedList = StateProvider<List<bool>>((ref) => []);
  final thematics = StateProvider<List<String>>((ref) => []);

  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  final TileLayer carteLayer = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    maxZoom: 20.0,
    userAgentPackageName: 'com.citeopolis.mobile_app_citeopolis',
  );
  final TileLayer tileLayerOptions = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    maxZoom: 20.0,
    userAgentPackageName: 'com.citeopolis.mobile_app_citeopolis',
  );

  final double defaultZoom = 13.0;
  bool withScaffold=false;
  TileMap tileMap = TileMap();
  List<MapXml> maps = [];
  final mapsFiltered = StateProvider<List<MapXml>>((ref) => []);
  List<TileMapId> orderedFieldsSingleList = [];

  static http.Client? _xmlHttpClient;

  http.Client get xmlHttpClient {
    _xmlHttpClient ??= http.Client();
    return _xmlHttpClient!;
  }

  bool hasActiveSearch(String searchText) => searchText.isNotEmpty;

  Future<void> initializeMap(WidgetRef ref, TileMap tileMap,bool withScaffold) async {
    if (isInitialized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isInitialized = true;
      this.tileMap = tileMap;
      this.withScaffold = withScaffold;
      searchController.clear();
      markers = {};
      maps.clear();
      ref.read(mapsFiltered.notifier).state.clear();
      orderedFieldsSingleList.clear();

      ref.read(selectedList.notifier).state.clear();
      ref.read(thematics.notifier).state.clear();
      startDate.clear();
      endDate.clear();
    });
  }

  final configProviderFamily = FutureProvider.family.autoDispose<void,TileMap>((ref,tileMap) async {
    final mapViewModel = ref.read(mapProvider);

    try {
      final url = tileMap.results?.urlTile ?? '';
      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlMaps = <XmlElement>[];
        for (final eventNode in document.findAllElements('point')) {
          allXmlMaps.add(eventNode);
        }

        final config = tileMap.results;
        final fieldsSingleList = mapViewModel.getVisibleOrderItems(config?.idsSingle);
        mapViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isNotEmpty) {
          final List<MapXml> listMaps = allXmlMaps.map((xmlElement) => MapXml.fromXml(xmlElement)).toList();

          final uniqueCategories = <String>{};
          for (final mapXml in listMaps) {
            if (mapXml.category.isNotEmpty) {
              uniqueCategories.add(mapXml.category);
            }
          }

          final sortedCategories = uniqueCategories.toList()..sort();
          ref.read(mapViewModel.thematics.notifier).state = sortedCategories;
          ref.read(mapViewModel.selectedList.notifier).state = List.generate(sortedCategories.length, (index) => false);

          mapViewModel.maps = listMaps;
          ref.read(mapViewModel.mapsFiltered.notifier).state = listMaps;

          mapViewModel._createMarkers(ref, mapViewModel.maps);
        }
      }
    } catch (e) {
      debugPrint('Error fetching XML configuration: $e');
    }
  });

  List<TileMapId> getVisibleOrderItems(List<TileMapId>? idsList) => idsList?.where((e) => e.status == 1).toList() ?? [];

  void _createMarkers(ref, List<MapXml> processedEvents) {
    markers.clear();
    for (int i = 0; i < processedEvents.length; i++) {
      final LatLng markerPosition = LatLng(processedEvents[i].location.latitude, processedEvents[i].location.longitude);
      markers[i.toString()] = Marker(
        point: markerPosition,
        child: GestureDetector(
          onTap: () {
            if (orderedFieldsSingleList.isNotEmpty) {
              showModal(ref, processedEvents[i]);
            }
          },
          child: AtomImage(
            imageType: ImageEnum.vectorAssets,
            assetPath: Assets.assetsImageMarker,
            size: const Size(48, 48),
            fit: BoxFit.contain,
          ),
        ),
        width: 48,
        height: 48,
      );
    }
  }

  void showModal(ref, MapXml mapXml) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: ref.watch(themeProvider).isDarkMode ? surfaceDark : surfaceLight,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: ref.watch(themeProvider).isDarkMode ? surfaceDark : surfaceLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
            boxShadow: [
              const BoxShadow(
                color: Color(0x4D000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
              const BoxShadow(
                color: Color(0x26000000),
                offset: Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ref.watch(themeProvider).isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: GestureDetector(
                        onTap: () {
                          NavigationService.push(
                            context,
                            ref,
                            Paths.detailCarte,
                            extra: {
                              'tileMap': tileMap,
                              'map': mapXml,
                              'allMap': maps,
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            30.ph,
                            ..._buildMpaFields(
                              context,
                              mapXml,
                              ref.watch(themeProvider).isDarkMode,
                              withScaffold ? searchController.text : ref.watch(homeProvider).searchController.text,
                            ),
                            100.ph,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 20,
                right: 20,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircleAvatar(
                    backgroundColor: ref.watch(themeProvider).isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: ref.watch(themeProvider).isDarkMode ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMpaFields(BuildContext context, MapXml mapXml, bool isDarkMode, String searchText) {
    final orderedFields = orderedFieldsSingleList;
    final widgets = <Widget>[];

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (mapXml.title.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: mapXml.title,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleLarge!,
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              15.ph,
            ]);
          }
          break;

        case 'mainimage':
          if (mapXml.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AtomUploadImage(
                    base64ImageData: mapXml.mainImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'category':
          if (mapXml.category.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: mapXml.category,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!,
                isDarkMode: isDarkMode,
              ),
              15.ph,
            ]);
          }
          break;
        case 'summary':
          if (mapXml.summary.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: mapXml.summary,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;
      }
    }

    return widgets;
  }

  void applyAllFilters(WidgetRef ref, String searchText) {
    final normalizedSearchText = searchText.trim().toLowerCase();
    final selectedStates = ref.read(selectedList);
    final allThematics = ref.read(thematics);
    final startDateText = startDate.text.trim();
    final endDateText = endDate.text.trim();

    List<MapXml> filteredMaps = List.from(maps);

    if (normalizedSearchText.isNotEmpty) {
      filteredMaps = filteredMaps.where((map) => _matchesSearchQuery(map, normalizedSearchText)).toList();
    }

    final selectedIndices = <int>[];
    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedIndices.add(i);
      }
    }

    if (selectedIndices.isNotEmpty) {
      final selectedThematicNames = selectedIndices.map((index) => allThematics[index].toLowerCase()).toList();
      filteredMaps = filteredMaps.where((mapXml) => selectedThematicNames.contains(mapXml.category.toLowerCase())).toList();
    }

    if (startDateText.isNotEmpty || endDateText.isNotEmpty) {
      filteredMaps = filteredMaps.where((article) => _isXmlMapWithinDateRange(article.pubDate, startDateText, endDateText)).toList();
    }

    ref.read(mapsFiltered.notifier).state = filteredMaps;
    _updateMarkersForFilteredResults(ref, filteredMaps);
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    applyAllFilters(ref, text);
  }

  bool _matchesSearchQuery(MapXml mapXml, String query) {
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      mapXml.title,
      mapXml.category,
      mapXml.summary,
      mapXml.content,
      mapXml.imageCaption,
      mapXml.mainImage,
      mapXml.pubDate,
      mapXml.updateDate,
      mapXml.eventStartDate,
      mapXml.eventEndDate,
      mapXml.eventStartTime,
      mapXml.eventEndTime,
      mapXml.location.title,
      mapXml.location.address,
      mapXml.location.postalCode,
      mapXml.location.city,
      mapXml.location.latitude.toString(),
      mapXml.location.longitude.toString(),
      mapXml.additionalInformation,
      mapXml.website,
      mapXml.phone1,
      mapXml.phone2,
      mapXml.email,
      mapXml.contact.fullName,
      mapXml.contact.firstName,
      mapXml.contact.lastName,
      mapXml.contact.phone,
      mapXml.contact.email,
      mapXml.facebook,
      mapXml.twitter,
      mapXml.instagram,
      mapXml.linkedin,
      mapXml.youtube,
      mapXml.downloadFile.icon,
      mapXml.downloadFile.title,
      mapXml.downloadFile.type,
      mapXml.downloadFile.size,
      mapXml.downloadFile.link,
      ...mapXml.schedule.map((schedule) => schedule.dayName),
      ...mapXml.schedule.map((schedule) => schedule.datetime),
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == mapXml.content) {
          fieldContent = _cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == mapXml.mainImage && field.isNotEmpty) {
          final fileName = field.split('/').last.toLowerCase();
          final fileNameWithoutExtension = fileName.split('.').first;

          if (fileName.contains(term) || fileNameWithoutExtension.contains(term)) {
            termFound = true;
            break;
          }
        }
      }

      if (!termFound) {
        return false;
      }
    }

    return true;
  }

  bool _isXmlMapWithinDateRange(String pubDateString, String startDateText, String endDateText) {
    if (pubDateString.isEmpty) return false;

    final pubDate = _parsePubDate(pubDateString);
    if (pubDate == null) return false;

    final startDate = _parseUserDate(startDateText);
    final endDate = _parseUserDate(endDateText);

    if (startDate != null && pubDate.isBefore(startDate)) {
      return false;
    }

    if (endDate != null) {
      final endOfDay = endDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
      if (pubDate.isAfter(endOfDay)) {
        return false;
      }
    }

    return true;
  }

  DateTime? _parseUserDate(String dateText) {
    if (dateText.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateText);
    } catch (e) {
      debugPrint('Erreur parsing date utilisateur: $e');
      return null;
    }
  }

  DateTime? _parsePubDate(String dateText) {
    if (dateText.isEmpty) return null;
    try {
      return DateTime.parse(dateText);
    } catch (e) {
      debugPrint('Erreur parsing pubDate: $e');
      return null;
    }
  }

  void _updateMarkersForFilteredResults(WidgetRef ref, List<MapXml> filteredMaps) {
    markers.clear();

    for (int i = 0; i < filteredMaps.length; i++) {
      final mapXml = filteredMaps[i];
      final LatLng markerPosition = LatLng(mapXml.location.latitude, mapXml.location.longitude);

      markers[i.toString()] = Marker(
        point: markerPosition,
        child: GestureDetector(
          onTap: () {
            showModal(ref, mapXml);
          },
          child: AtomImage(
            imageType: ImageEnum.vectorAssets,
            assetPath: Assets.assetsImageMarker,
            size: const Size(48, 48),
            fit: BoxFit.contain,
          ),
        ),
        width: 48,
        height: 48,
      );
    }

    notifyListeners();
  }

  Future<void> getUserLocation(WidgetRef ref) async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied) {
          return;
        }
      }

      final LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      mapController.move(
        LatLng(position.latitude, position.longitude),
        defaultZoom,
      );
    } catch (e) {
      debugPrint("Erreur lors de l'obtention de la localisation: $e");
    }
  }

  String _cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return '';
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'&\w+;'), ' ').trim().toLowerCase();
  }

  void disposeGlobalResources() {
    CustomNetworkTileProvider.disposeClient();
  }

  @override
  void dispose() {
    mapController.dispose();

    _xmlHttpClient?.close();
    _xmlHttpClient = null;
    disposeGlobalResources();

    super.dispose();
  }

  Widget atomEndDrawerMap(WidgetRef ref, GlobalKey<ScaffoldState> scaffoldKey, bool isDarkMode) => AtomEndDrawer(
        scaffoldKey: scaffoldKey,
        textFilter: 'Filtrer la carte',
        isDarkMode: isDarkMode,
        thematicListFilter: ref.watch(thematics),
        selectedList: ref.watch(selectedList),
        onSelected: (value, index) {
          ref.read(selectedList.notifier).update(
                (state) => [
                  for (int j = 0; j < state.length; j++)
                    if (j == index) value else state[j],
                ],
              );
        },
        onApplyFilters: () => applyAllFilters(ref, searchController.text),
        startDate: startDate,
        endDate: endDate,
      );
}

class CustomNetworkTileProvider extends TileProvider {
  static http.Client? _httpClient;

  static http.Client get httpClient {
    _httpClient ??= http.Client();
    return _httpClient!;
  }

  static void disposeClient() {
    _httpClient?.close();
    _httpClient = null;
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) => NetworkImage(
        getTileUrl(coordinates, options),
        headers: headers,
      );

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final urlTemplate = options.urlTemplate!;
    return urlTemplate.replaceAll('{z}', coordinates.z.toString()).replaceAll('{x}', coordinates.x.toString()).replaceAll('{y}', coordinates.y.toString()).replaceAll(
          '{s}',
          getSubdomain(coordinates, options),
        );
  }

  String getSubdomain(TileCoordinates coordinates, TileLayer options) {
    final subdomains = options.subdomains;
    if (subdomains.isEmpty) return '';
    return subdomains[(coordinates.x + coordinates.y) % subdomains.length];
  }

  @override
  Map<String, String> get headers => {
        'User-Agent': 'Flutter Map Example',
      };
}
