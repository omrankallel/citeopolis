import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/services/injector.dart';
import '../../domain/modals/tile.dart';
import '../../domain/repositories/tile_repository.dart';
import '../mapper/tile/tile_list_mapper.dart';
import '../service/tile_service.dart';
import 'tile_detail_repository_impl.dart';

class TileRepositoryImpl implements TileRepository {
  final TileService _tileService;
  final TileDetailRepositoryImpl _tileDetailService;
  final ConnectivityService _connectivityService;

  final LocalStorageListService<Tile> _tileStorage = getIt<LocalStorageListService<Tile>>();

  TileRepositoryImpl(
    this._tileService,
    this._tileDetailService,
    this._connectivityService,
  );

  @override
  Future<Either<String, List<Tile>>> getTileProject(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getTileProjectFromServer(idProject);
      } else {
        return await getTileProjectFromLocal(idProject);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tile: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Tile>>> getTileProjectFromServer(int idProject) async {
    try {
      final tileList = await _tileService.getTileProject(idProject);
      return tileList.fold((l) => Left(l), (apiData) async {
        final mappedTiles = TileListMapper.transformToModel(apiData);
        final tilesWithDetails = await _fetchDetailsForTiles(mappedTiles);
        await _saveToLocalStorage(idProject, tilesWithDetails);
        return Right(tilesWithDetails);
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tile depuis le serveur: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Tile>>> getTileProjectFromLocal(int idProject) async {
    try {
      final localData = _tileStorage.get(idProject.toString());
      if (localData != null && localData.isNotEmpty) {
        return Right(localData);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getTileProjectFromServer(idProject);
        } else {
          return const Right([]);
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération locale: $e');
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<List<Tile>> _fetchDetailsForTiles(List<Tile> tiles) async {
    final results = await Future.wait(
      tiles.map((tile) async {
        try {
          if (tile.id != null && tile.type?.slug != null) {
            final detailResult = await _tileDetailService.getTileDetail(
              (tile.id ?? 0).toString(),
              tile.type!.slug!,
            );
            return detailResult.fold(
              (error) => tile,
              (details) => tile.copyWith(
                id: tile.id,
                title: tile.title,
                projectId: tile.projectId,
                publishTile: tile.publishTile,
                type: tile.type,
                details: details,
              ),
            );
          }
          return tile;
        } catch (e) {
          debugPrint('Erreur lors de la récupération des détails pour tile ${tile.id}: $e');
          return tile;
        }
      }),
    );
    return results;
  }

  Future<void> _saveToLocalStorage(int idProject, List<Tile> tileList) async {
    try {
      await _tileStorage.save(idProject.toString(), tileList);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde locale tile: $e');
    }
  }
}
