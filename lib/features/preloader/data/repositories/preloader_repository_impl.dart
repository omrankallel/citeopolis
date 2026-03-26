import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/memory/local_storage_service.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/image_app/image_service.dart';
import '../../../../core/services/image_app/image_service_impl.dart';
import '../../../../core/services/injector.dart';
import '../../domain/modals/config_app.dart';
import '../../domain/repositories/preloader_repository.dart';
import '../mapper/config_app/config_app_mapper.dart';
import '../service/preloader_service.dart';

class PreloaderRepositoryImpl implements PreloaderRepository {
  final PreloaderService _preloaderService;
  final ConnectivityService _connectivityService;
  final ImageService _imageService;

  final LocalStorageService<ConfigApp> _preloaderStorage = getIt<LocalStorageService<ConfigApp>>();

  PreloaderRepositoryImpl(
    this._preloaderService,
    this._connectivityService, [
    ImageService? imageService,
  ]) : _imageService = imageService ?? ImageServiceImpl();

  @override
  Future<Either<String, ConfigApp>> getConfigProject(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getConfigProjectFromServer(idProject);
      } else {
        return await getConfigProjectFromLocal(idProject);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ConfigApp>> getConfigProjectFromServer(int idProject) async {
    try {
      final config = await _preloaderService.getConfigProject(idProject);

      return config.fold((l) => Left(l), (apiData) async {
        final newConfig = ConfigAppMapper.transformToModel(apiData);
        final oldConfig = _preloaderStorage.get(idProject.toString());

        await _saveAllImagesLocally(newConfig, oldConfig);
        await _deleteObsoleteImages(oldConfig, newConfig);
        await _saveToLocalStorage(idProject, newConfig);

        return Right(newConfig);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ConfigApp>> getConfigProjectFromLocal(int idProject) async {
    try {
      final localData = _preloaderStorage.get(idProject.toString());
      if (localData != null) {
        await _verifyLocalImages(idProject, localData);
        return Right(localData);
      } else {
        return const Left('Aucune donnée locale disponible');
      }
    } catch (e) {
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveAllImagesLocally(ConfigApp newConfig, ConfigApp? oldConfig) async {
    final imageTasks = <Future<void>>[];

    final bgUrl = newConfig.configuration?.backgroundApp?.url;
    final bgFilename = newConfig.configuration?.backgroundApp?.filename;
    final oldBgUrl = oldConfig?.configuration?.backgroundApp?.url;
    final oldBgPath = oldConfig?.configuration?.backgroundApp?.localPath;

    if (bgUrl != null && bgFilename != null) {
      if (oldBgPath != null && oldBgUrl == bgUrl) {
        newConfig.configuration!.backgroundApp!.localPath = oldBgPath;
      } else {
        imageTasks.add(() async {
          final path = await _saveImageLocally(bgUrl, bgFilename);
          if (path != null) newConfig.configuration!.backgroundApp!.localPath = path;
        }());
      }
    }

    final logoUrl = newConfig.configuration?.logoApp?.url;
    final logoFilename = newConfig.configuration?.logoApp?.filename;
    final oldLogoUrl = oldConfig?.configuration?.logoApp?.url;
    final oldLogoPath = oldConfig?.configuration?.logoApp?.localPath;

    if (logoUrl != null && logoFilename != null) {
      if (oldLogoPath != null && oldLogoUrl == logoUrl) {
        newConfig.configuration!.logoApp!.localPath = oldLogoPath;
      } else {
        imageTasks.add(() async {
          final path = await _saveImageLocally(logoUrl, logoFilename);
          if (path != null) newConfig.configuration!.logoApp!.localPath = path;
        }());
      }
    }

    if (newConfig.configuration?.partnerRepeater != null) {
      final oldPartners = oldConfig?.configuration?.partnerRepeater ?? [];
      for (int i = 0; i < newConfig.configuration!.partnerRepeater!.length; i++) {
        final partner = newConfig.configuration!.partnerRepeater![i];
        if (partner.url == null || partner.filename == null) continue;

        final oldPartner = oldPartners.length > i ? oldPartners[i] : null;
        if (oldPartner?.localPath != null && oldPartner?.url == partner.url) {
          partner.localPath = oldPartner!.localPath;
          continue;
        }

        final idx = i;
        imageTasks.add(() async {
          final path = await _saveImageLocally(partner.url!, partner.filename!);
          if (path != null) {
            newConfig.configuration!.partnerRepeater![idx].localPath = path;
          }
        }());
      }
    }

    if (imageTasks.isNotEmpty) await Future.wait(imageTasks);
  }

  Future<void> _deleteObsoleteImages(ConfigApp? oldConfig, ConfigApp newConfig) async {
    if (oldConfig == null) return;
    try {
      final oldBgPath = oldConfig.configuration?.backgroundApp?.localPath;
      final newBgPath = newConfig.configuration?.backgroundApp?.localPath;
      if (oldBgPath != null && oldBgPath != newBgPath) {
        await _deleteImageFile(oldBgPath);
      }

      final oldLogoPath = oldConfig.configuration?.logoApp?.localPath;
      final newLogoPath = newConfig.configuration?.logoApp?.localPath;
      if (oldLogoPath != null && oldLogoPath != newLogoPath) {
        await _deleteImageFile(oldLogoPath);
      }

      final oldPartners = oldConfig.configuration?.partnerRepeater ?? [];
      final newPartners = newConfig.configuration?.partnerRepeater ?? [];
      for (final oldPartner in oldPartners) {
        if (oldPartner.localPath == null) continue;
        final stillUsed = newPartners.any((p) => p.localPath == oldPartner.localPath);
        if (!stillUsed) await _deleteImageFile(oldPartner.localPath!);
      }
    } catch (e) {
      debugPrint('Erreur suppression images obsolètes preloader: $e');
    }
  }

  Future<void> _deleteImageFile(String localPath) async {
    try {
      await _imageService.deleteLocalImage(localPath);
    } catch (e) {
      debugPrint('Erreur suppression image $localPath: $e');
    }
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
      return null;
    }
  }

  Future<void> _verifyLocalImages(int idProject, ConfigApp configApp) async {
    try {
      bool hasChanges = false;
      final configuration = configApp.configuration;

      if (configuration?.backgroundApp?.localPath != null) {
        final exists = await _imageService.imageExistsLocally(configuration!.backgroundApp!.localPath!);
        if (!exists) {
          configApp.configuration!.backgroundApp!.localPath = null;
          hasChanges = true;
        }
      }

      if (configuration?.logoApp?.localPath != null) {
        final exists = await _imageService.imageExistsLocally(configuration!.logoApp!.localPath!);
        if (!exists) {
          configApp.configuration!.logoApp!.localPath = null;
          hasChanges = true;
        }
      }

      if (configuration?.partnerRepeater != null) {
        for (var partner in configuration!.partnerRepeater!) {
          if (partner.localPath != null) {
            final exists = await _imageService.imageExistsLocally(partner.localPath!);
            if (!exists) {
              partner.localPath = null;
              hasChanges = true;
            }
          }
        }
      }

      if (hasChanges) await _saveToLocalStorage(idProject, configApp);
    } catch (e) {
      debugPrint('Erreur vérification images preloader: $e');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, ConfigApp configApp) async {
    try {
      if (configApp.id != null) {
        await _preloaderStorage.save(idProject.toString(), configApp);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde preloader: $e');
    }
  }
}
