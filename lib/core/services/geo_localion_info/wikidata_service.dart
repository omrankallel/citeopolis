import 'dart:convert';


import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'geo_location_info.dart';

class WikidataService {
  static const String _baseUrl = 'https://www.wikidata.org/w/api.php';
  static const String _wikimediaBase = 'https://upload.wikimedia.org/wikipedia/commons';
  static const String _wikimediaApi = 'https://commons.wikimedia.org/w/api.php';

  static final Map<String, String?> _labelCache = {};
  static final Map<String, String?> _imageUrlCache = {};

  static Future<String?> findEntityByCoordinates(
    double latitude,
    double longitude, {
    int radius = 1000,
  }) async {
    try {
      final url = '$_baseUrl?action=query&list=geosearch&gscoord=$latitude|$longitude&gsradius=$radius&gslimit=1&format=json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint('Erreur HTTP ${response.statusCode} lors de la recherche géographique');
        return null;
      }

      final data = jsonDecode(response.body);
      final searchResults = data['query']['geosearch'] as List;

      if (searchResults.isEmpty) {
        debugPrint('Aucune entité trouvée pour les coordonnées: $latitude, $longitude');
        return null;
      }

      final result = searchResults.first;
      String entityId = result['title'] as String;

      if (entityId.contains(':')) {
        final parts = entityId.split(':');
        entityId = parts.length > 1 ? parts[1] : parts[0];
      }

      entityId = entityId.replaceAll(RegExp(r'[^Q0-9]'), '');

      debugPrint('Entity ID trouvé: $entityId pour coordonnées: $latitude, $longitude');
      return entityId.isNotEmpty ? entityId : null;
    } catch (e) {
      debugPrint('Erreur lors de la recherche géographique: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getEntityData(String entityId) async {
    try {
      final url = 'https://www.wikidata.org/wiki/Special:EntityData/$entityId.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint("Erreur HTTP ${response.statusCode} pour l'entité: $entityId");
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['entities'] == null || data['entities'][entityId] == null) {
        debugPrint('Entité non trouvée: $entityId');
        return null;
      }

      return data['entities'][entityId] as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'entité $entityId: $e");
      return null;
    }
  }

  static Future<String?> getEntityLabel(String entityId) async {
    if (_labelCache.containsKey(entityId)) {
      return _labelCache[entityId];
    }

    try {
      final entityData = await getEntityData(entityId);
      if (entityData == null) {
        _labelCache[entityId] = null;
        return null;
      }

      final labels = entityData['labels'] as Map<String, dynamic>?;
      if (labels == null) {
        _labelCache[entityId] = null;
        return null;
      }

      String? label;
      if (labels['fr'] != null) {
        label = labels['fr']['value'] as String;
      } else if (labels['en'] != null) {
        label = labels['en']['value'] as String;
      } else if (labels.isNotEmpty) {
        final firstLang = labels.keys.first;
        label = labels[firstLang]['value'] as String;
      }

      _labelCache[entityId] = label;
      return label;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du label pour $entityId: $e');
      _labelCache[entityId] = null;
      return null;
    }
  }

  static Future<String?> getImageUrl(String imageName) async {
    if (_imageUrlCache.containsKey(imageName)) {
      return _imageUrlCache[imageName];
    }

    try {
      final directUrl = await _buildDirectImageUrl(imageName);
      if (directUrl != null) {
        _imageUrlCache[imageName] = directUrl;
        return directUrl;
      }

      final apiUrl = await _getImageUrlViaAPI(imageName);
      _imageUrlCache[imageName] = apiUrl;
      return apiUrl;
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'URL d'image: $e");
      _imageUrlCache[imageName] = null;
      return null;
    }
  }

  static Future<String?> _buildDirectImageUrl(String imageName) async {
    try {
      final nameForHash = imageName.replaceAll(' ', '_');
      final hash = md5.convert(utf8.encode(nameForHash)).toString();

      if (hash.length < 2) return null;

      final hashPath = '${hash[0]}/${hash.substring(0, 2)}';
      final nameSimple = imageName.replaceAll(' ', '_');
      final nameEncoded = Uri.encodeComponent(imageName).replaceAll('%20', '_');

      final urls = [
        '$_wikimediaBase/thumb/$hashPath/$nameSimple/300px-$nameSimple',
        '$_wikimediaBase/thumb/$hashPath/$nameEncoded/300px-$nameEncoded',
        '$_wikimediaBase/$hashPath/$nameSimple',
        '$_wikimediaBase/thumb/$hashPath/$nameSimple/280px-$nameSimple',
        '$_wikimediaBase/thumb/$hashPath/$nameSimple/320px-$nameSimple',
      ];

      for (final url in urls) {
        try {
          final response = await http.head(Uri.parse(url));
          if (response.statusCode == 200) {
            debugPrint("✅ URL d'image directe trouvée: $url");
            return url;
          }
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      debugPrint("Erreur lors de la construction directe de l'URL: $e");
      return null;
    }
  }

  static Future<String?> _getImageUrlViaAPI(String imageName) async {
    try {
      final url = '$_wikimediaApi?action=query&titles=File:${Uri.encodeComponent(imageName)}&prop=imageinfo&iiprop=url&iiurlwidth=300&format=json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final pages = data['query']['pages'] as Map<String, dynamic>?;

      if (pages != null) {
        for (final pageId in pages.keys) {
          final page = pages[pageId] as Map<String, dynamic>;
          final imageInfo = page['imageinfo'] as List?;

          if (imageInfo != null && imageInfo.isNotEmpty) {
            final info = imageInfo[0] as Map<String, dynamic>;

            if (info['thumburl'] != null) {
              debugPrint('✅ URL thumbnail trouvée via API: ${info['thumburl']}');
              return info['thumburl'] as String;
            } else if (info['url'] != null) {
              debugPrint('✅ URL originale trouvée via API: ${info['url']}');
              return info['url'] as String;
            }
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Erreur API Wikimedia: $e');
      return null;
    }
  }

  static Future<GeoLocationInfo?> getLocationInfo(
    double latitude,
    double longitude,
  ) async {
    try {
      final entityId = await findEntityByCoordinates(latitude, longitude);
      if (entityId == null) return null;

      final entityData = await getEntityData(entityId);
      if (entityData == null) return null;

      final claims = entityData['claims'] as Map<String, dynamic>?;
      final labels = entityData['labels'] as Map<String, dynamic>?;
      final descriptions = entityData['descriptions'] as Map<String, dynamic>?;

      String? name;
      if (labels != null) {
        if (labels['fr'] != null) {
          name = labels['fr']['value'] as String;
        } else if (labels['en'] != null) {
          name = labels['en']['value'] as String;
        } else if (labels.isNotEmpty) {
          final firstLang = labels.keys.first;
          name = labels[firstLang]['value'] as String;
        }
      }

      String? description;
      if (descriptions != null) {
        if (descriptions['fr'] != null) {
          description = descriptions['fr']['value'] as String;
        } else if (descriptions['en'] != null) {
          description = descriptions['en']['value'] as String;
        } else if (descriptions.isNotEmpty) {
          final firstLang = descriptions.keys.first;
          description = descriptions[firstLang]['value'] as String;
        }
      }

      String? type;
      if (claims != null && claims['P31'] != null) {
        try {
          final p31List = claims['P31'] as List;
          if (p31List.isNotEmpty) {
            final instanceData = p31List[0]['mainsnak'];
            final instanceId = instanceData['datavalue']?['value']?['id'] as String?;
            if (instanceId != null) {
              type = await getEntityLabel(instanceId);
            }
          }
        } catch (e) {
          debugPrint("Erreur lors de l'extraction du type: $e");
        }
      }

      String? imageUrl;
      if (claims != null && claims['P18'] != null) {
        try {
          final p18List = claims['P18'] as List;
          if (p18List.isNotEmpty) {
            final imageData = p18List[0]['mainsnak'];
            final imageName = imageData['datavalue']?['value'] as String?;
            if (imageName != null) {
              imageUrl = await getImageUrl(imageName);
            }
          }
        } catch (e) {
          debugPrint("Erreur lors de l'extraction de l'image: $e");
        }
      }

      final locationInfo = GeoLocationInfo(
        name: name,
        type: type,
        description: description,
        imageUrl: imageUrl,
      );

      debugPrint('✅ Informations géolocalisées récupérées pour: $name');
      return locationInfo;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des informations géolocalisées: $e');
      return null;
    }
  }

  static void clearCache() {
    _labelCache.clear();
    _imageUrlCache.clear();
  }
}
