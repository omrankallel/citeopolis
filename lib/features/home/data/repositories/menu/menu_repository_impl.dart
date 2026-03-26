import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/services/injector.dart';
import '../../../domain/modals/menu/menu.dart';
import '../../../domain/repositories/menu/menu_repository.dart';
import '../../mapper/menu/menu_list_mapper.dart';
import '../../service/menu/menu_service.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuService _menuService;
  final ConnectivityService _connectivityService;

  final LocalStorageListService<Menu> _menuStorage = getIt<LocalStorageListService<Menu>>();

  MenuRepositoryImpl(
    this._menuService,
    this._connectivityService,
  );

  @override
  Future<Either<String, List<Menu>>> getMenuProject(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getMenuProjectFromServer(idProject);
      } else {
        return await getMenuProjectFromLocal(idProject);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des menu: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Menu>>> getMenuProjectFromServer(int idProject) async {
    try {
      final menuList = await _menuService.getMenuProject(idProject);
      return menuList.fold((l) => Left(l), (apiData) async {
        final mappedMenus = MenuListMapper.transformToModel(apiData);
        await _saveToLocalStorage(idProject, mappedMenus);
        return Right(mappedMenus);
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des menu depuis le serveur: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Menu>>> getMenuProjectFromLocal(int idProject) async {
    try {
      final localData = _menuStorage.get(idProject.toString());
      if (localData != null && localData.isNotEmpty) {
        return Right(localData);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getMenuProjectFromServer(idProject);
        } else {
          return const Right([]);
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération locale: $e');
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, List<Menu> menuList) async {
    try {
      await _menuStorage.save(idProject.toString(), menuList);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde locale menu: $e');
    }
  }
}
