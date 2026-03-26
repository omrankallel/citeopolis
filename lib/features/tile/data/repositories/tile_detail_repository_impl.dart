import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../core/memory/local_storage_service.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/services/image_app/image_service.dart';
import '../../../../../core/services/image_app/image_service_impl.dart';
import '../../../../../core/services/injector.dart';
import '../../domain/modals/tile_content.dart';
import '../../../map/domain/modals/tile_map.dart';
import '../../domain/modals/tile_quick_access.dart';
import '../../domain/modals/tile_url.dart';
import '../../domain/modals/tile_xml.dart';
import '../../domain/repositories/tile_detail_repository.dart';
import '../service/tile_detail_service.dart';

class TileDetailRepositoryImpl implements TileDetailRepository {
  final TileDetailService _tileDetailService;
  final ConnectivityService _connectivityService;
  final ImageService _imageService;

  final LocalStorageService<TileUrl> _tileUrlStorage = getIt<LocalStorageService<TileUrl>>();
  final LocalStorageService<TileQuickAccess> _tileQuickAccessStorage = getIt<LocalStorageService<TileQuickAccess>>();
  final LocalStorageService<TileContent> _tileContentStorage = getIt<LocalStorageService<TileContent>>();
  final LocalStorageService<TileMap> _tileMapStorage = getIt<LocalStorageService<TileMap>>();
  final LocalStorageService<TileXml> _tileXmlStorage = getIt<LocalStorageService<TileXml>>();

  TileDetailRepositoryImpl(
      this._tileDetailService,
      this._connectivityService, [
        ImageService? imageService,
      ]) : _imageService = imageService ?? ImageServiceImpl();

  @override
  Future<Either<String, dynamic>> getTileDetail(String tileId, String tileType) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();

      if (hasConnection) {
        return await getTileDetailFromServer(tileId, tileType);
      } else {
        return await getTileDetailFromLocal(tileId, tileType);
      }
    } catch (e) {
      final localResult = await getTileDetailFromLocal(tileId, tileType);
      return localResult.fold(
            (localError) => Left('Erreur réseau et locale: $e'),
            (tileData) => Right(tileData),
      );
    }
  }

  @override
  Future<Either<String, dynamic>> getTileDetailFromServer(String tileId, String tileType) async {
    try {
      final tileDetail = await _tileDetailService.getTileDetail(int.parse(tileId));
      return tileDetail.fold((l) => Left(l), (apiData) async {
        final mappedTile = _mapToSpecificTileType(apiData, tileType);
        if (mappedTile != null) {
          await _clearAllDataBeforeSave(tileId, tileType);
          await _saveAllImagesLocally(tileId, tileType, mappedTile);
          await _saveToLocalStorage(tileId, tileType, mappedTile);

          return Right(_convertToMap(tileType, mappedTile));
        }
        return Left('Type de tile non supporté: $tileType');
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération du détail tile depuis le serveur: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> getTileDetailFromLocal(String tileId, String tileType) async {
    try {
      final localData = _getFromLocalStorage(tileId, tileType);
      if (localData != null) {
        await _verifyLocalImages(tileId, tileType, localData);

        return Right(_convertToMap(tileType, localData));
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getTileDetailFromServer(tileId, tileType);
        } else {
          return Left('Aucune donnée locale trouvée pour le tile $tileId');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération locale: $e');
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  /// Convertit l'objet typé en Map<String, dynamic>
  Map<String, dynamic> _convertToMap(String tileType, dynamic tileData) {
    switch (tileType.toLowerCase()) {
      case 'fo_tul':
        return (tileData as TileUrl).toJson();
      case 'fo_tua':
        return (tileData as TileQuickAccess).toJson();
      case 'fo_tup':
        return (tileData as TileContent).toJson();
      case 'fo_tuc':
        return (tileData as TileMap).toJson();
      case 'fo_tux':
        return (tileData as TileXml).toJson();
      default:
        return {};
    }
  }

  /// 🧹 Supprime TOUTES les anciennes données (storage + images) avant sauvegarde
  Future<void> _clearAllDataBeforeSave(String tileId, String tileType) async {
    try {
      debugPrint('🧹 Suppression des anciennes données TileDetail ($tileType)...');

      final oldData = _getFromLocalStorage(tileId, tileType);
      if (oldData != null) {
        await _deleteAllImagesFromTile(tileType, oldData);
        debugPrint('🗑️ Anciennes images TileDetail supprimées');
      }

      await _deleteFromLocalStorage(tileId, tileType);
      debugPrint('🗑️ Ancien storage TileDetail supprimé');

      debugPrint('✅ Nettoyage TileDetail terminé');
    } catch (e) {
      debugPrint('⚠️ Erreur lors du nettoyage TileDetail: $e');
    }
  }

  /// 💾 Sauvegarde toutes les images trouvées dans les tiles
  Future<void> _saveAllImagesLocally(String tileId, String tileType, dynamic tileData) async {
    try {
      switch (tileType.toLowerCase()) {
        case 'fo_tua': // TileQuickAccess
          await _saveTileQuickAccessImages(tileData as TileQuickAccess);
          break;
        case 'fo_tup': // TileContent
          await _saveTileContentImages(tileData as TileContent);
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde images TileDetail: $e');
    }
  }

  /// Sauvegarde les images de TileQuickAccess (fo_tua)
  Future<void> _saveTileQuickAccessImages(TileQuickAccess tileQuickAccess) async {
    try {
      if (tileQuickAccess.results?.data != null) {
        for (var row in tileQuickAccess.results!.data!) {
          if (row.pictogram != null && (row.pictogram?.url??'').isNotEmpty) {
            final filename = _generateFilename(row.pictogram!.url!, 'tile_quick_access');
            final localPath = await _saveImageLocally(row.pictogram!.url!, filename);
            if (localPath != null) {
              row.pictogram!.localPath = localPath;
            }
          }
        }
      }
      debugPrint('✅ Images TileQuickAccess sauvegardées');
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde images TileQuickAccess: $e');
    }
  }

  /// Sauvegarde les images de TileContent (fo_tup)
  Future<void> _saveTileContentImages(TileContent tileContent) async {
    try {
      if (tileContent.results?.imgTile != null && tileContent.results!.imgTile!.isNotEmpty) {
        final filename = _generateFilename(tileContent.results!.imgTile!, 'tile_content_main');
        final localPath = await _saveImageLocally(tileContent.results!.imgTile!, filename);
        if (localPath != null) {
          tileContent.results!.localPath = localPath;
        }
      }
      debugPrint('✅ Images TileContent sauvegardées');
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde images TileContent: $e');
    }
  }

  /// 🗑️ Supprime toutes les images d'un tile
  Future<void> _deleteAllImagesFromTile(String tileType, dynamic tileData) async {
    try {
      switch (tileType.toLowerCase()) {
        case 'fo_tua':
          await _deleteTileQuickAccessImages(tileData as TileQuickAccess);
          break;
        case 'fo_tup':
          await _deleteTileContentImages(tileData as TileContent);
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur suppression images TileDetail: $e');
    }
  }

  Future<void> _deleteTileQuickAccessImages(TileQuickAccess tileQuickAccess) async {
    try {
      if (tileQuickAccess.results?.data != null) {
        for (var row in tileQuickAccess.results!.data!) {
          if (row.pictogram!.localPath != null) {
            await _deleteImageFile(row.pictogram!.localPath!);
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur suppression images TileQuickAccess: $e');
    }
  }

  Future<void> _deleteTileContentImages(TileContent tileContent) async {
    try {
      if (tileContent.results?.localPath != null) {
        await _deleteImageFile(tileContent.results!.localPath!);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur suppression images TileContent: $e');
    }
  }

  /// Vérifie l'existence de toutes les images locales
  Future<void> _verifyLocalImages(String tileId, String tileType, dynamic tileData) async {
    try {
      bool hasChanges = false;

      switch (tileType.toLowerCase()) {
        case 'fo_tua':
          hasChanges = await _verifyTileQuickAccessImages(tileData as TileQuickAccess);
          break;
        case 'fo_tup':
          hasChanges = await _verifyTileContentImages(tileData as TileContent);
          break;
      }

      if (hasChanges) {
        await _saveToLocalStorage(tileId, tileType, tileData);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur vérification images: $e');
    }
  }

  Future<bool> _verifyTileQuickAccessImages(TileQuickAccess tileQuickAccess) async {
    bool hasChanges = false;
    try {
      if (tileQuickAccess.results?.data != null) {
        for (var row in tileQuickAccess.results!.data!) {
          if (row.pictogram!.localPath != null) {
            final imageExists = await _imageService.imageExistsLocally(row.pictogram!.localPath!);
            if (!imageExists) {
              hasChanges = true;
              row.pictogram!.localPath = null;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur vérification images TileQuickAccess: $e');
    }
    return hasChanges;
  }

  Future<bool> _verifyTileContentImages(TileContent tileContent) async {
    bool hasChanges = false;
    try {
      if (tileContent.results?.localPath != null) {
        final imageExists = await _imageService.imageExistsLocally(tileContent.results!.localPath!);
        if (!imageExists) {
          hasChanges = true;
          tileContent.results!.localPath = null;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur vérification images TileContent: $e');
    }
    return hasChanges;
  }

  Future<void> _deleteImageFile(String localPath) async {
    try {
      final success = await _imageService.deleteLocalImage(localPath);
      if (success) {
        debugPrint('🗑️ Image supprimée: $localPath');
      } else {
        debugPrint('⚠️ Impossible de supprimer: $localPath');
      }
    } catch (e) {
      debugPrint('⚠️ Erreur suppression image $localPath: $e');
    }
  }

  String _generateFilename(String imageUrl, String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _getImageExtension(imageUrl);
    return '${type}_$timestamp$extension';
  }

  String _getImageExtension(String imageUrl) {
    if (imageUrl.contains('.jpg') || imageUrl.contains('.jpeg')) {
      return '.jpg';
    } else if (imageUrl.contains('.png')) {
      return '.png';
    } else if (imageUrl.contains('.gif')) {
      return '.gif';
    } else if (imageUrl.contains('.webp')) {
      return '.webp';
    }
    return '.jpg';
  }

  Future<String?> _saveImageLocally(String imageUrl, String filename) async {
    try {
      if (imageUrl.startsWith('http')) {
        return await _imageService.saveImageToLocal(imageUrl, filename);
      } else if (imageUrl.contains('base64') || imageUrl.length > 100) {
        return await _imageService.saveBase64ImageToLocal(imageUrl, filename);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde image: $e');
      return null;
    }
  }

  Future<void> _deleteFromLocalStorage(String tileId, String tileType) async {
    try {
      switch (tileType.toLowerCase()) {
        case 'fo_tul':
          await _tileUrlStorage.delete(tileId);
          break;
        case 'fo_tua':
          await _tileQuickAccessStorage.delete(tileId);
          break;
        case 'fo_tup':
          await _tileContentStorage.delete(tileId);
          break;
        case 'fo_tuc':
          await _tileMapStorage.delete(tileId);
          break;
        case 'fo_tux':
          await _tileXmlStorage.delete(tileId);
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la suppression locale: $e');
    }
  }

  dynamic _mapToSpecificTileType(Map<String, dynamic> apiData, String tileType) {
    switch (tileType.toLowerCase()) {
      case 'fo_tul':
        return TileUrl.fromJson(apiData);
      case 'fo_tua':
        return TileQuickAccess.fromJson(apiData);
      case 'fo_tup':
        return TileContent.fromJson(apiData);
      case 'fo_tuc':
        return TileMap.fromJson(apiData);
      case 'fo_tux':
        return TileXml.fromJson(apiData);
      default:
        return null;
    }
  }

  dynamic _getFromLocalStorage(String tileId, String tileType) {
    switch (tileType.toLowerCase()) {
      case 'fo_tul':
        return _tileUrlStorage.get(tileId);
      case 'fo_tua':
        return _tileQuickAccessStorage.get(tileId);
      case 'fo_tup':
        return _tileContentStorage.get(tileId);
      case 'fo_tuc':
        return _tileMapStorage.get(tileId);
      case 'fo_tux':
        return _tileXmlStorage.get(tileId);
      default:
        return null;
    }
  }

  Future<void> _saveToLocalStorage(String tileId, String tileType, dynamic tileData) async {
    try {
      switch (tileType.toLowerCase()) {
        case 'fo_tul':
          await _tileUrlStorage.save(tileId, tileData as TileUrl);
          break;
        case 'fo_tua':
          await _tileQuickAccessStorage.save(tileId, tileData as TileQuickAccess);
          break;
        case 'fo_tup':
          await _tileContentStorage.save(tileId, tileData as TileContent);
          break;
        case 'fo_tuc':
          await _tileMapStorage.save(tileId, tileData as TileMap);
          break;
        case 'fo_tux':
          await _tileXmlStorage.save(tileId, tileData as TileXml);
          break;
      }
      debugPrint('💾 TileDetail sauvegardé: $tileType');
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la sauvegarde locale: $e');
    }
  }

  Future<void> clearAllTileDetails() async {
    try {
      debugPrint('🧹 Suppression de tous les détails tiles...');

      await _tileUrlStorage.clear();
      await _tileQuickAccessStorage.clear();
      await _tileContentStorage.clear();
      await _tileMapStorage.clear();
      await _tileXmlStorage.clear();

      debugPrint('✅ Nettoyage des détails tiles terminé');
    } catch (e) {
      debugPrint('⚠️ Erreur lors du nettoyage des détails tiles: $e');
    }
  }
}