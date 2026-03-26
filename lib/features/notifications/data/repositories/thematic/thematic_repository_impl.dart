import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/network/connectivity_provider.dart';
import '../../../../../../core/services/injector.dart';
import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../domain/modals/thematic/thematic.dart';
import '../../../domain/repositories/thematic/thematic_repository.dart';
import '../../mapper/thematic/thematic_list_mapper.dart';
import '../../service/thematic/thematic_service.dart';

class ThematicRepositoryImpl implements ThematicRepository {
  final ThematicService _thematicService;
  final ConnectivityService _connectivityService;
  final LocalStorageListService<Thematic> _buildPageStorage = getIt<LocalStorageListService<Thematic>>();

  ThematicRepositoryImpl(
    this._thematicService,
    this._connectivityService,
  );

  @override
  Future<Either<String, List<Thematic>>> getThematic(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getThematicFromServer(idProject);
      } else {
        return await getThematicFromLocal(idProject);
      }
    } catch (e) {
      final localResult = await getThematicFromLocal(idProject);
      return localResult.fold(
        (localError) => Left('Erreur réseau et locale: $e'),
        (buildPage) => Right(buildPage),
      );
    }
  }

  @override
  Future<Either<String, List<Thematic>>> getThematicFromServer(int idProject) async {
    try {
      final thematicList = await _thematicService.getThematic(idProject);
      return thematicList.fold((l) => Left(l), (apiData) async {
        final mappedThematic = ThematicListMapper.transformToModel(apiData);
        await _saveToLocalStorage(idProject, mappedThematic);
        return Right(mappedThematic);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Thematic>>> getThematicFromLocal(int idProject) async {
    try {
      final localData = _buildPageStorage.get(idProject.toString());
      if (localData != null) {
        return Right(localData);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getThematicFromServer(idProject);
        } else {
          return const Right([]);
        }
      }
    } catch (e) {
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, List<Thematic> thematics) async {
    try {
      await _buildPageStorage.save(idProject.toString(), thematics);
    } catch (e) {
      debugPrint('Erreur sauvegarde thematic: $e');
    }
  }
}
