import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../core/services/geo_localion_info/geo_location_info.dart';
import '../../../../../../core/services/geo_localion_info/wikidata_service.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../favorites/domain/factories/favorite_factory.dart';
import '../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../domain/modals/tile_map.dart';
import '../../domain/modals/xml_map.dart';
import 'map_view_model.dart';

final detailMapXmlProvider = ChangeNotifierProvider.autoDispose((ref) => DetailMapXmlProvider());

class DetailMapXmlProvider extends ChangeNotifier {
  bool isInitialized = false;
  String favoriteButtonTag = '';

  final searchController = TextEditingController();

  bool isEmpty = false;

  final isFavorite = StateProvider<bool>((ref) => false);
  final allMapXml = StateProvider<List<MapXml>>((ref) => []);
  final fieldsConfiguration = StateProvider<List<TileMapId>>((ref) => []);

  List<TileMapId> orderedFieldsListItem = [];

  List<TileMapId> orderedFieldsSingleList = [];

  Future<void> initMapXml(WidgetRef ref, TileMap tileMap, List<MapXml>? allMapXml, MapXml mapXml) async {
    if (!isInitialized) {
      isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!ref.context.mounted) return;
        favoriteButtonTag = '${tileMap.results?.urlTile ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}';
        searchController.clear();

        orderedFieldsListItem.clear();

        final fieldsListItem = getVisibleOrderItems(tileMap.results?.idsList);
        orderedFieldsListItem = fieldsListItem;

        ref.read(isFavorite.notifier).state = isFavoriteMapXml(ref, tileMap.id ?? '0', mapXml);

        await loadRecommendedMapXml(ref, tileMap, allMapXml);
        if (!ref.context.mounted) return;
        notifyListeners();
      });
    }
  }

  Future<void> loadRecommendedMapXml(WidgetRef ref, TileMap tileMap, List<MapXml>? allMapXml) async {
    if (allMapXml != null && allMapXml.isNotEmpty) {
      setAllMapXml(allMapXml, ref);
      final fieldsConfig = ref.read(mapProvider).orderedFieldsSingleList;
      if (fieldsConfig.isNotEmpty) {
        setFieldsConfiguration(fieldsConfig, ref);
      }
    } else {
      final mapXml = await ref.read(configProvider(tileMap).future);
      if (!ref.context.mounted) return;

      setAllMapXml(mapXml, ref);
      final fieldsConfig = orderedFieldsSingleList;
      setFieldsConfiguration(fieldsConfig, ref);
    }
  }

  final configProvider = FutureProvider.family.autoDispose<List<MapXml>, TileMap>((ref, tileMap) async {
    try {
      final detailMapXmlViewModel = ref.read(detailMapXmlProvider);

      final url = tileMap.results?.urlTile ?? '';

      if (url.isEmpty) return [];

      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlMaps = <XmlElement>[];
        for (final eventNode in document.findAllElements('point')) {
          allXmlMaps.add(eventNode);
        }

        final config = tileMap.results;

        final fieldsSingleList = detailMapXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        detailMapXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isEmpty) {
          return [];
        }

        final List<MapXml> listMapXml = [];
        listMapXml.addAll(allXmlMaps.map((xmlElement) => MapXml.fromXml(xmlElement)).toList());

        return listMapXml;
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching mapXml: $e');
      return [];
    }
  });

  void setAllMapXml(List<MapXml> mapXml, WidgetRef ref) {
    ref.read(allMapXml.notifier).state = mapXml;
  }

  void setFieldsConfiguration(List<TileMapId> fields, WidgetRef ref) {
    ref.read(fieldsConfiguration.notifier).state = fields;
  }

  List<MapXml> getRecommendedMapXml(MapXml currentMapXml, WidgetRef ref) {
    final mapXml = ref.read(allMapXml);
    return mapXml.where((mapXml) => mapXml.title != currentMapXml.title).toList();
  }

  List<TileMapId> getVisibleOrderItems(List<TileMapId>? idsList) => idsList?.where((field) => field.status == 1).toList() ?? [];

  String generateFavoriteId(String tileMapId, MapXml mapXml) => 'map_xml_${tileMapId}_${mapXml.title.hashCode}';

  bool isFavoriteMapXml(WidgetRef ref, String tileMapId, MapXml mapXml) {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = generateFavoriteId(tileMapId, mapXml);
    return useCase.isFavorite(favoriteId);
  }

  Future<void> onPressFavorite(WidgetRef ref, TileMap tileMap, MapXml currentMapXml) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final tileMapId = tileMap.id ?? '0';
    final favoriteId = generateFavoriteId(tileMapId, currentMapXml);

    final favorite = FavoriteFactory.fromTileMap(tileMap, currentMapXml);
    favorite.id = favoriteId;
    favorite.title = currentMapXml.title;
    favorite.imageUrl = currentMapXml.mainImage;

    final currentIsFavorite = ref.read(isFavorite);
    ref.read(isFavorite.notifier).state = !currentIsFavorite;

    try {
      final result = currentIsFavorite ? await useCase.removeFromFavorites(favorite.id) : await useCase.addToFavorites(favorite);

      result.fold(
        (error) {
          ref.read(isFavorite.notifier).state = currentIsFavorite;
          Helpers.showSnackBar(ref.context, 'Erreur: $error', Colors.red);
        },
        (success) {
          ref.read(updateFavorites.notifier).state = !ref.read(updateFavorites);
          final message = !currentIsFavorite ? 'Ajouté aux favoris' : 'Supprimé des favoris';
          Helpers.showSnackBar(ref.context, message, Colors.green);
        },
      );
    } catch (e) {
      ref.read(isFavorite.notifier).state = currentIsFavorite;
      if (ref.context.mounted) {
        Helpers.showSnackBar(ref.context, 'Erreur inattendue: $e', Colors.red);
      }
    }
  }

  Future<void> onSearchTextChanged(WidgetRef ref, MapXml mapXml, String search) async {
    if (search.isEmpty) {
      isEmpty = false;
      notifyListeners();
      return;
    }

    final searchLower = search.toLowerCase();
    final searchTerms = searchLower.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      mapXml.title,
      mapXml.category,
      mapXml.summary,
      mapXml.content,
      mapXml.imageCaption,
      mapXml.mainImage,
      mapXml.pubDate,
      mapXml.updateDate,
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == mapXml.content) {
          fieldContent = cleanHtmlContent(field);
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
        isEmpty = true;
        notifyListeners();
        return;
      }
    }

    isEmpty = false;
    notifyListeners();
  }

  String cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return '';
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'&\w+;'), ' ').trim().toLowerCase();
  }

  final Map<String, GeoLocationInfo?> _geoLocationCache = {};
  final Map<String, bool> _loadingGeoLocationState = {};

  Map<String, GeoLocationInfo?> get geoLocationCache => _geoLocationCache;

  Map<String, bool> get loadingGeoLocationState => _loadingGeoLocationState;

  String _getLocationKey(double latitude, double longitude) => '${latitude}_$longitude';

  bool hasGeoLocationInfo(double latitude, double longitude) {
    final key = _getLocationKey(latitude, longitude);
    return _geoLocationCache.containsKey(key) && _geoLocationCache[key] != null;
  }

  GeoLocationInfo? getGeoLocationInfo(double latitude, double longitude) {
    final key = _getLocationKey(latitude, longitude);
    return _geoLocationCache[key];
  }

  bool isLoadingGeoLocation(double latitude, double longitude) {
    final key = _getLocationKey(latitude, longitude);
    return _loadingGeoLocationState[key] ?? false;
  }

  Future<GeoLocationInfo?> fetchGeoLocationInfo(double latitude, double longitude) async {
    final key = _getLocationKey(latitude, longitude);

    if (_geoLocationCache.containsKey(key)) {
      return _geoLocationCache[key];
    }

    if (_loadingGeoLocationState[key] != null && _loadingGeoLocationState[key]!) {
      return null;
    }

    _loadingGeoLocationState[key] = true;
    notifyListeners();

    try {
      final locationInfo = await WikidataService.getLocationInfo(latitude, longitude);

      _geoLocationCache[key] = locationInfo;
      _loadingGeoLocationState[key] = false;

      notifyListeners();

      if (locationInfo != null) {
        debugPrint('✅ Informations géolocalisées récupérées pour: ${locationInfo.name}');
      } else {
        debugPrint('❌ Aucune information trouvée pour: $latitude, $longitude');
      }

      return locationInfo;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des informations géolocalisées: $e');
      _geoLocationCache[key] = null;
      _loadingGeoLocationState[key] = false;
      notifyListeners();
      return null;
    }
  }

  void clearGeoLocationCache() {
    _geoLocationCache.clear();
    _loadingGeoLocationState.clear();
    WikidataService.clearCache();
    notifyListeners();
    debugPrint('🗑️ Cache géolocalisé vidé');
  }

  @override
  void dispose() {
    clearGeoLocationCache();
    searchController.dispose();
    super.dispose();
  }
}
