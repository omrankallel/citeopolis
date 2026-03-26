import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../core/memory/local_storage_list_service.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/services/injector.dart';
import '../../domain/modals/term.dart';
import '../../domain/repositories/term_repository.dart';
import '../mapper/term/term_list_mapper.dart';
import '../service/term_service.dart';

class TermRepositoryImpl implements TermRepository {
  final TermService _termService;
  final ConnectivityService _connectivityService;

  final LocalStorageListService<Term> _termStorage = getIt<LocalStorageListService<Term>>();

  TermRepositoryImpl(
    this._termService,
    this._connectivityService,
  );

  @override
  Future<Either<String, List<Term>>> getTermProject(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getTermProjectFromServer(idProject);
      } else {
        return await getTermProjectFromLocal(idProject);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des term: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Term>>> getTermProjectFromServer(int idProject) async {
    try {
      final termList = await _termService.getTermProject(idProject);
      return termList.fold((l) => Left(l), (apiData) async {
        final mappedTerms = TermListMapper.transformToModel(apiData);
        await _saveToLocalStorage(idProject, mappedTerms);
        return Right(mappedTerms);
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des term depuis le serveur: $e');
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Term>>> getTermProjectFromLocal(int idProject) async {
    try {
      final localData = _termStorage.get(idProject.toString());
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

  Future<void> _saveToLocalStorage(int idProject, List<Term> termList) async {
    try {
      await _termStorage.save(idProject.toString(), termList);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde locale term: $e');
    }
  }
}
