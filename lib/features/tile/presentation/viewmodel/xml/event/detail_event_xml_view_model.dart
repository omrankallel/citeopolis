import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../core/services/geo_localion_info/geo_location_info.dart';
import '../../../../../../core/services/geo_localion_info/wikidata_service.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../favorites/domain/factories/favorite_factory.dart';
import '../../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_event.dart';
import 'events_xml_view_model.dart';

final detailEventXmlProvider = ChangeNotifierProvider.autoDispose((ref) => DetailEventXmlProvider());

class DetailEventXmlProvider extends ChangeNotifier {
  bool isInitialized = false;
  String favoriteButtonTag = '';

  final searchController = TextEditingController();

  bool isEmpty = false;

  final isFavorite = StateProvider<bool>((ref) => false);
  final allEvents = StateProvider<List<Event>>((ref) => []);
  final fieldsConfiguration = StateProvider<List<TileXmlId>>((ref) => []);

  List<TileXmlId> orderedFieldsListItem = [];

  List<TileXmlId> orderedFieldsSingleList = [];

  Future<void> initEventsXml(WidgetRef ref, TileXml tileXml, List<Event>? allEvents, Event event) async {
    if (!isInitialized) {
      isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!ref.context.mounted) return;
        favoriteButtonTag = '${tileXml.results?.urlTile ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}';
        searchController.clear();

        orderedFieldsListItem.clear();

        final fieldsListItem = getVisibleOrderItems(tileXml.results?.idsList);
        orderedFieldsListItem = fieldsListItem;

        ref.read(isFavorite.notifier).state = isFavoriteEvent(ref, tileXml.id ?? '0', event);

        await loadRecommendedEvents(ref, tileXml, allEvents);
        if (!ref.context.mounted) return;
        notifyListeners();
      });
    }
  }

  Future<void> loadRecommendedEvents(WidgetRef ref, TileXml tileXml, List<Event>? allEvents) async {
    if (allEvents != null && allEvents.isNotEmpty) {
      setAllEvents(allEvents, ref);
      final fieldsConfig = ref.read(eventsXmlProvider).orderedFieldsSingleList;
      if (fieldsConfig.isNotEmpty) {
        setFieldsConfiguration(fieldsConfig, ref);
      }
    } else {
      final events = await ref.read(configProvider(tileXml).future);
      if (!ref.context.mounted) return;

      setAllEvents(events, ref);
      final fieldsConfig = orderedFieldsSingleList;
      setFieldsConfiguration(fieldsConfig, ref);
    }
  }

  final configProvider = FutureProvider.family.autoDispose<List<Event>, TileXml>((ref, tileXml) async {
    try {
      final detailEventXmlViewModel = ref.read(detailEventXmlProvider);

      final url = tileXml.results?.urlTile ?? '';
      final numberElement = int.parse(tileXml.results?.numberElement ?? '0');

      if (url.isEmpty) return [];

      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlEvents = <XmlElement>[];
        for (final eventNode in document.findAllElements('event')) {
          allXmlEvents.add(eventNode);
        }

        final config = tileXml.results;

        final fieldsSingleList = detailEventXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        detailEventXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isEmpty) {
          return [];
        }

        final List<Event> listEvents = [];
        listEvents.addAll(allXmlEvents.map((xmlElement) => Event.fromXml(xmlElement)).toList());

        return listEvents.take(numberElement).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  });

  void setAllEvents(List<Event> events, WidgetRef ref) {
    ref.read(allEvents.notifier).state = events;
  }

  void setFieldsConfiguration(List<TileXmlId> fields, WidgetRef ref) {
    ref.read(fieldsConfiguration.notifier).state = fields;
  }

  List<Event> getRecommendedEvents(Event currentEvent, WidgetRef ref) {
    final events = ref.read(allEvents);
    return events.where((event) => event.title != currentEvent.title).toList();
  }

  List<TileXmlId> getVisibleOrderItems(List<TileXmlId>? idsList) => idsList?.where((field) => field.status == 1).toList() ?? [];

  String generateFavoriteId(String tileXmlId, Event event) => 'tile_xml_${tileXmlId}_${event.title.hashCode}';

  bool isFavoriteEvent(WidgetRef ref, String tileXmlId, Event event) {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = generateFavoriteId(tileXmlId, event);
    return useCase.isFavorite(favoriteId);
  }

  Future<void> onPressFavorite(WidgetRef ref, TileXml tileXml, Event currentEvent) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final tileXmlId = tileXml.id ?? '0';
    final favoriteId = generateFavoriteId(tileXmlId, currentEvent);

    final favorite = FavoriteFactory.fromEventXml(tileXml, currentEvent);
    favorite.id = favoriteId;
    favorite.title = currentEvent.title;
    favorite.imageUrl = currentEvent.mainImage;

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

  Future<void> onSearchTextChanged(WidgetRef ref, Event event, String search) async {
    if (search.isEmpty) {
      isEmpty = false;
      notifyListeners();
      return;
    }

    final searchLower = search.toLowerCase();
    final searchTerms = searchLower.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      event.title,
      event.category,
      event.summary,
      event.content,
      event.imageCaption,
      event.mainImage,
      event.pubDate,
      event.updateDate,
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == event.content) {
          fieldContent = cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == event.mainImage && field.isNotEmpty) {
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
