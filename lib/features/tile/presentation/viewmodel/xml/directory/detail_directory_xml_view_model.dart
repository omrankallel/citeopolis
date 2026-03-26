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
import '../../../../domain/modals/xml/xml_directory.dart';
import 'directories_xml_view_model.dart';

final detailDirectoryXmlProvider = ChangeNotifierProvider.autoDispose((ref) => DetailDirectoryXmlProvider());

class DetailDirectoryXmlProvider extends ChangeNotifier {
  bool isInitialized = false;
  String favoriteButtonTag = '';

  final searchController = TextEditingController();

  bool isEmpty = false;

  final isFavorite = StateProvider<bool>((ref) => false);
  final allDirectories = StateProvider<List<Directory>>((ref) => []);
  final fieldsConfiguration = StateProvider<List<TileXmlId>>((ref) => []);

  List<TileXmlId> orderedFieldsListItem = [];

  List<TileXmlId> orderedFieldsSingleList = [];

  Future<void> initDirectoriesXml(WidgetRef ref, TileXml tileXml, List<Directory>? allDirectories, Directory directory) async {
    if (!isInitialized) {
      isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!ref.context.mounted) return;
        favoriteButtonTag = '${tileXml.results?.urlTile ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}';
        searchController.clear();

        orderedFieldsListItem.clear();

        final fieldsListItem = getVisibleOrderItems(tileXml.results?.idsList);
        orderedFieldsListItem = fieldsListItem;

        ref.read(isFavorite.notifier).state = isFavoriteDirectory(ref, tileXml.id ?? '0', directory);

        await loadRecommendedDirectories(ref, tileXml, allDirectories);
        if (!ref.context.mounted) return;
        notifyListeners();
      });
    }
  }

  Future<void> loadRecommendedDirectories(WidgetRef ref, TileXml tileXml, List<Directory>? allDirectories) async {
    if (allDirectories != null && allDirectories.isNotEmpty) {
      setAllDirectories(allDirectories, ref);
      final fieldsConfig = ref.read(directoriesXmlProvider).orderedFieldsSingleList;
      if (fieldsConfig.isNotEmpty) {
        setFieldsConfiguration(fieldsConfig, ref);
      }
    } else {
      final directories = await ref.read(configProvider(tileXml).future);
      if (!ref.context.mounted) return;

      setAllDirectories(directories, ref);
      final fieldsConfig = orderedFieldsSingleList;
      setFieldsConfiguration(fieldsConfig, ref);
    }
  }

  final configProvider = FutureProvider.family.autoDispose<List<Directory>, TileXml>((ref, tileXml) async {
    try {
      final detailDirectoryXmlViewModel = ref.read(detailDirectoryXmlProvider);

      final url = tileXml.results?.urlTile ?? '';
      final numberElement = int.parse(tileXml.results?.numberElement ?? '0');

      if (url.isEmpty) return [];

      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlDirectories = <XmlElement>[];
        for (final directoryNode in document.findAllElements('entry')) {
          allXmlDirectories.add(directoryNode);
        }

        final config = tileXml.results;

        final fieldsSingleList = detailDirectoryXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        detailDirectoryXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isEmpty) {
          return [];
        }

        final List<Directory> listDirectories = [];
        listDirectories.addAll(allXmlDirectories.map((xmlElement) => Directory.fromXml(xmlElement)).toList());

        return listDirectories.take(numberElement).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching directories: $e');
      return [];
    }
  });

  void setAllDirectories(List<Directory> directories, WidgetRef ref) {
    ref.read(allDirectories.notifier).state = directories;
  }

  void setFieldsConfiguration(List<TileXmlId> fields, WidgetRef ref) {
    ref.read(fieldsConfiguration.notifier).state = fields;
  }

  List<Directory> getRecommendedDirectories(Directory currentDirectory, WidgetRef ref) {
    final directories = ref.read(allDirectories);
    return directories.where((directory) => directory.title != currentDirectory.title).toList();
  }

  List<TileXmlId> getVisibleOrderItems(List<TileXmlId>? idsList) => idsList?.where((field) => field.status == 1).toList() ?? [];

  String generateFavoriteId(String tileXmlId, Directory directory) => 'tile_xml_${tileXmlId}_${directory.title.hashCode}';

  bool isFavoriteDirectory(WidgetRef ref, String tileXmlId, Directory directory) {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = generateFavoriteId(tileXmlId, directory);
    return useCase.isFavorite(favoriteId);
  }

  Future<void> onPressFavorite(WidgetRef ref, TileXml tileXml, Directory currentDirectory) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final tileXmlId = tileXml.id ?? '0';
    final favoriteId = generateFavoriteId(tileXmlId, currentDirectory);

    final favorite = FavoriteFactory.fromDirectoryXml(tileXml, currentDirectory);
    favorite.id = favoriteId;
    favorite.title = currentDirectory.title;
    favorite.imageUrl = currentDirectory.mainImage;

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

  Future<void> onSearchTextChanged(WidgetRef ref, Directory directory, String search) async {
    if (search.isEmpty) {
      isEmpty = false;
      notifyListeners();
      return;
    }

    final searchLower = search.toLowerCase();
    final searchTerms = searchLower.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      directory.title,
      directory.category,
      directory.summary,
      directory.content,
      directory.imageCaption,
      directory.mainImage,
      directory.pubDate.toString(),
      directory.updateDate.toString(),
      directory.additionalInformation,
      directory.website,
      directory.phone1,
      directory.phone2,
      directory.email,
      directory.contact.firstName,
      directory.contact.lastName,
      directory.contact.phone,
      directory.contact.email,
      directory.location.title,
      directory.location.address,
      directory.location.postalCode,
      directory.location.city,
      directory.location.latitude.toString(),
      directory.location.longitude.toString(),
      directory.facebook,
      directory.twitter,
      directory.instagram,
      directory.linkedin,
      directory.youtube,
      ...directory.schedule.map(
        (s) => '${s.dayName} ${s.datetime}',
      ),
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == directory.content) {
          fieldContent = cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == directory.mainImage && field.isNotEmpty) {
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
