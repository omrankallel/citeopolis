import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/memory/local_storage_service.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/image_app/image_service.dart';
import '../../../../core/services/image_app/image_service_impl.dart';
import '../../../../core/services/injector.dart';
import '../../domain/modals/publicity.dart';
import '../../domain/repositories/publicity_repository.dart';
import '../mapper/publicity/publicity_mapper.dart';
import '../service/publicity_service.dart';

class PublicityRepositoryImpl implements PublicityRepository {
  final PublicityService _publicityService;
  final ConnectivityService _connectivityService;
  final ImageService _imageService;

  final LocalStorageService<Publicity> _publicityStorage = getIt<LocalStorageService<Publicity>>();

  PublicityRepositoryImpl(
    this._publicityService,
    this._connectivityService, [
    ImageService? imageService,
  ]) : _imageService = imageService ?? ImageServiceImpl();

  @override
  Future<Either<String, Publicity>> getPublicity(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getPublicityFromServer(idProject);
      } else {
        return await getPublicityFromLocal(idProject);
      }
    } catch (e) {
      final localResult = await getPublicityFromLocal(idProject);
      return localResult.fold(
        (localError) => Left('Erreur réseau et locale: $e'),
        (publicity) => Right(publicity),
      );
    }
  }

  @override
  Future<Either<String, Publicity>> getPublicityFromServer(int idProject) async {
    try {
      final publicity = await _publicityService.getPublicity(idProject);

      return publicity.fold((l) => Left(l), (apiData) async {
        final newPublicity = PublicityMapper.transformToModel(apiData);
        final oldPublicity = _publicityStorage.get(idProject.toString());

        await _saveImageLocally(newPublicity, oldPublicity);

        if (oldPublicity?.imgPublicity?.localPath != null && oldPublicity?.imgPublicity?.localPath != newPublicity.imgPublicity?.localPath) {
          await _deleteImageFile(oldPublicity!.imgPublicity!.localPath!);
        }

        await _saveToLocalStorage(idProject, newPublicity);
        return Right(newPublicity);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Publicity>> getPublicityFromLocal(int idProject) async {
    try {
      final localData = _publicityStorage.get(idProject.toString());
      if (localData != null) {
        await _verifyLocalImages(idProject, localData);
        return Right(localData);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getPublicityFromServer(idProject);
        } else {
          return Right(Publicity());
        }
      }
    } catch (e) {
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveImageLocally(Publicity newPublicity, Publicity? oldPublicity) async {
    try {
      final url = newPublicity.imgPublicity?.url;
      final filename = newPublicity.imgPublicity?.filename;
      if (url == null || filename == null) return;

      final oldUrl = oldPublicity?.imgPublicity?.url;
      final oldPath = oldPublicity?.imgPublicity?.localPath;

      if (oldPath != null && oldUrl == url) {
        newPublicity.imgPublicity!.localPath = oldPath;
        return;
      }

      final localPath = await _saveImageToLocal(url, filename);
      if (localPath != null) {
        newPublicity.imgPublicity!.localPath = localPath;
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde image publicity: $e');
    }
  }

  Future<String?> _saveImageToLocal(String imageUrl, String filename) async {
    try {
      if (imageUrl.startsWith('http')) {
        return await _imageService.saveImageToLocal(imageUrl, filename);
      } else if (imageUrl.contains('base64') || imageUrl.length > 100) {
        return await _imageService.saveBase64ImageToLocal(imageUrl, filename);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteImageFile(String localPath) async {
    try {
      await _imageService.deleteLocalImage(localPath);
    } catch (e) {
      debugPrint('Erreur suppression image $localPath: $e');
    }
  }

  Future<void> _verifyLocalImages(int idProject, Publicity publicity) async {
    try {
      if (publicity.imgPublicity?.localPath != null) {
        final exists = await _imageService.imageExistsLocally(publicity.imgPublicity!.localPath!);
        if (!exists) {
          publicity.imgPublicity!.localPath = null;
          await _saveToLocalStorage(idProject, publicity);
        }
      }
    } catch (e) {
      debugPrint('Erreur vérification images publicity: $e');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, Publicity publicity) async {
    try {
      await _publicityStorage.save(idProject.toString(), publicity);
    } catch (e) {
      debugPrint('Erreur sauvegarde publicity: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      final allItems = _publicityStorage.getAll();
      for (var publicity in allItems) {
        if (publicity.imgPublicity?.localPath != null) {
          await _deleteImageFile(publicity.imgPublicity!.localPath!);
        }
      }
      await _publicityStorage.clear();
    } catch (e) {
      debugPrint('Erreur nettoyage cache publicity: $e');
    }
  }
}
