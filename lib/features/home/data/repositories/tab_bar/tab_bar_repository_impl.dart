import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../core/memory/local_storage_list_service.dart';
import '../../../../../../core/network/connectivity_provider.dart';
import '../../../../../../core/services/image_app/image_service.dart';
import '../../../../../../core/services/image_app/image_service_impl.dart';
import '../../../../../../core/services/injector.dart';
import '../../../domain/modals/tab_bar/tab_bar.dart';
import '../../../domain/repositories/tab_bar/tab_bar_repository.dart';
import '../../mapper/tab_bar/tab_bar_list_mapper.dart';
import '../../service/tab_bar/tab_bar_service.dart';

class TabBarRepositoryImpl implements TabBarRepository {
  final TabBarService _tabBarService;
  final ConnectivityService _connectivityService;
  final ImageService _imageService;

  final LocalStorageListService<TabBar> _tabBarStorage = getIt<LocalStorageListService<TabBar>>();

  TabBarRepositoryImpl(
    this._tabBarService,
    this._connectivityService, [
    ImageService? imageService,
  ]) : _imageService = imageService ?? ImageServiceImpl();

  @override
  Future<Either<String, List<TabBar>>> getTabBarProject(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getTabBarProjectFromServer(idProject);
      } else {
        return await getTabBarProjectFromLocal(idProject);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tab bars: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TabBar>>> getTabBarProjectFromServer(int idProject) async {
    try {
      final tabBarList = await _tabBarService.getTabBarProject(idProject);
      return tabBarList.fold((l) => Left(l), (apiData) async {
        final mappedTabBars = TabBarListMapper.transformToModel(apiData);
        final oldData = _tabBarStorage.get(idProject.toString());

        await _saveAllImagesLocally(mappedTabBars, oldData);
        await _deleteObsoleteImages(oldData, mappedTabBars);
        await _saveToLocalStorage(idProject, mappedTabBars);
        return Right(mappedTabBars);
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tab bars depuis le serveur: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TabBar>>> getTabBarProjectFromLocal(int idProject) async {
    try {
      final localData = _tabBarStorage.get(idProject.toString());
      if (localData != null && localData.isNotEmpty) {
        await _verifyLocalImages(idProject, localData);
        return Right(localData);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getTabBarProjectFromServer(idProject);
        } else {
          return const Right([]);
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération locale: $e');
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveAllImagesLocally(List<TabBar> tabBarList, List<TabBar>? oldData) async {
    try {
      final imageTasks = <Future<void>>[];
      for (int i = 0; i < tabBarList.length; i++) {
        final tabBar = tabBarList[i];
        final url = tabBar.pictoImg?.url;
        final filename = tabBar.pictoImg?.filename;
        if (url == null || filename == null) continue;

        final oldTabBar = oldData?.firstWhere((o) => o.tile == tabBar.tile, orElse: () => TabBar());
        if (oldTabBar?.pictoImg?.localPath != null && oldTabBar?.pictoImg?.url == url) {
          tabBarList[i].pictoImg!.localPath = oldTabBar!.pictoImg!.localPath;
          continue;
        }

        imageTasks.add(() async {
          final localPath = await _saveImageLocally(url, filename);
          if (localPath != null) tabBarList[i].pictoImg!.localPath = localPath;
        }());
      }
      if (imageTasks.isNotEmpty) await Future.wait(imageTasks);
    } catch (e) {
      debugPrint('Erreur sauvegarde images tab bar: $e');
    }
  }

  Future<void> _deleteObsoleteImages(List<TabBar>? oldData, List<TabBar> newData) async {
    if (oldData == null) return;
    try {
      for (final old in oldData) {
        if (old.pictoImg?.localPath == null) continue;
        final stillUsed = newData.any((t) => t.pictoImg?.localPath == old.pictoImg!.localPath);
        if (!stillUsed) await _deleteImageFile(old.pictoImg!.localPath!);
      }
    } catch (e) {
      debugPrint('Erreur suppression images obsolètes tab bar: $e');
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

  Future<void> _verifyLocalImages(int idProject, List<TabBar> tabBarList) async {
    try {
      bool hasChanges = false;
      for (var tabBar in tabBarList) {
        if (tabBar.pictoImg?.localPath != null) {
          final exists = await _imageService.imageExistsLocally(tabBar.pictoImg!.localPath!);
          if (!exists) {
            tabBar.pictoImg!.localPath = null;
            hasChanges = true;
          }
        }
      }
      if (hasChanges) await _saveToLocalStorage(idProject, tabBarList);
    } catch (e) {
      debugPrint('Erreur vérification images tab bar: $e');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, List<TabBar> tabBarList) async {
    try {
      await _tabBarStorage.save(idProject.toString(), tabBarList);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde locale tab bar: $e');
    }
  }
}
