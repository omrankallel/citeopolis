import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/services/injector.dart';
import '../../domain/modals/feed.dart';
import '../../domain/repositories/feed_repository.dart';
import '../mapper/feed/feed_list_mapper.dart';
import '../service/feed_service.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedService _feedService;
  final ConnectivityService _connectivityService;

  final LocalStorageListService<Feed> _feedStorage = getIt<LocalStorageListService<Feed>>();

  FeedRepositoryImpl(
    this._feedService,
    this._connectivityService,
  );

  @override
  Future<Either<String, List<Feed>>> getFeedProject(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getFeedProjectFromServer(idProject);
      } else {
        return await getFeedProjectFromLocal(idProject);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des feed: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Feed>>> getFeedProjectFromServer(int idProject) async {
    try {
      final feedList = await _feedService.getFeedProject(idProject);
      return feedList.fold((l) => Left(l), (apiData) async {
        final mappedFeeds = FeedListMapper.transformToModel(apiData);
        await _saveToLocalStorage(idProject, mappedFeeds);
        return Right(mappedFeeds);
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des feed depuis le serveur: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Feed>>> getFeedProjectFromLocal(int idProject) async {
    try {
      final localData = _feedStorage.get(idProject.toString());
      if (localData != null && localData.isNotEmpty) {
        return Right(localData);
      } else {
        return const Right([]);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération locale: $e');
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveToLocalStorage(int idProject, List<Feed> feedList) async {
    try {
      await _feedStorage.save(idProject.toString(), feedList);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde locale feed: $e');
    }
  }
}
