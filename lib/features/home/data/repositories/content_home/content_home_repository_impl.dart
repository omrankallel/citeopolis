import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/memory/local_storage_service.dart';
import '../../../../../../core/network/connectivity_provider.dart';
import '../../../../../../core/services/image_app/image_service_impl.dart';
import '../../../../../../core/services/injector.dart';
import '../../../../../core/services/image_app/image_service.dart';
import '../../../domain/modals/content_home/build_page.dart';
import '../../../domain/modals/content_home/flux_xml_rss_channel.dart';
import '../../../domain/modals/content_home/section.dart';
import '../../../domain/repositories/content_home/content_home_repository.dart';
import '../../mapper/content_home/build_page/build_page_mapper.dart';
import '../../service/content_home/content_home_service.dart';
import '../../service/content_home/flux_rss_service.dart';

class ContentHomeRepositoryImpl implements ContentHomeRepository {
  final ContentHomeService _contentHomeService;
  final FluxRSSService _fluxRSSService;
  final ConnectivityService _connectivityService;
  final ImageService _imageService;
  final LocalStorageService<BuildPage> _buildPageStorage = getIt<LocalStorageService<BuildPage>>();

  ContentHomeRepositoryImpl(
    this._contentHomeService,
    this._fluxRSSService,
    this._connectivityService, [
    ImageService? imageService,
  ]) : _imageService = imageService ?? ImageServiceImpl();

  @override
  Future<Either<String, BuildPage>> getPageHome(int idProject) async {
    try {
      final hasConnection = await _connectivityService.hasConnection();
      if (hasConnection) {
        return await getPageHomeFromServer(idProject);
      } else {
        return await getPageHomeFromLocal(idProject);
      }
    } catch (e) {
      final localResult = await getPageHomeFromLocal(idProject);
      return localResult.fold(
        (localError) => Left('Erreur réseau et locale: $e'),
        (buildPage) => Right(buildPage),
      );
    }
  }

  @override
  Future<Either<String, BuildPage>> getPageHomeFromServer(int idProject) async {
    try {
      final buildPage = await _contentHomeService.getPageHome(idProject);

      return buildPage.fold((l) => Left(l), (apiData) async {
        final newBuildPage = BuildPageMapper.transformToModel(apiData);

        final oldData = _buildPageStorage.get(idProject.toString());

        await Future.wait([
          _saveAllImagesLocally(newBuildPage, oldData),
          _fetchAndIntegrateAllRSSFeeds(newBuildPage),
        ]);

        if (oldData != null) {
          await _deleteObsoleteImages(oldData, newBuildPage);
        }

        await _saveToLocalStorage(idProject, newBuildPage);
        return Right(newBuildPage);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, BuildPage>> getPageHomeFromLocal(int idProject) async {
    try {
      final localData = _buildPageStorage.get(idProject.toString());
      if (localData != null) {
        await _verifyLocalImages(idProject, localData);
        return Right(localData);
      } else {
        final hasConnection = await _connectivityService.hasConnection();
        if (hasConnection) {
          return await getPageHomeFromServer(idProject);
        } else {
          return Right(BuildPage());
        }
      }
    } catch (e) {
      return Left('Erreur lors de la récupération locale: ${e.toString()}');
    }
  }

  Future<void> _saveAllImagesLocally(BuildPage buildPage, BuildPage? oldData) async {
    try {
      final List<Section> sections = buildPage.sections ?? [];
      final List<Section> oldSections = oldData?.sections ?? [];

      final List<Future<void>> imageTasks = [];

      for (int i = 0; i < sections.length; i++) {
        final Section section = sections[i];
        final String type = section.type ?? '';

        final Section? oldSection = oldSections.length > i ? oldSections[i] : null;

        switch (type) {
          case 'carousel':
            if (section.carrousel?.carrouselRepeater != null) {
              for (int j = 0; j < section.carrousel!.carrouselRepeater!.length; j++) {
                final repeater = section.carrousel!.carrouselRepeater![j];
                if (repeater.repPictoImg != null) {
                  final oldRepeater = (oldSection?.carrousel?.carrouselRepeater?.length ?? 0) > j ? oldSection?.carrousel?.carrouselRepeater![j] : null;
                  if (oldRepeater?.localPath != null && oldRepeater?.repPictoImg == repeater.repPictoImg) {
                    repeater.localPath = oldRepeater!.localPath;
                    continue;
                  }
                  imageTasks.add(() async {
                    final filename = _generateFilename(repeater.repPictoImg!, 'carrousel');
                    repeater.localPath = await _saveImageLocally(repeater.repPictoImg!, filename);
                  }());
                }
              }
            }
            break;

          case 'quick_access':
            if (section.quickAccess?.rows != null) {
              for (int j = 0; j < section.quickAccess!.rows!.length; j++) {
                final row = section.quickAccess!.rows![j];
                if (row.pictogram != null) {
                  final oldRow = (oldSection?.quickAccess?.rows?.length ?? 0) > j ? oldSection?.quickAccess?.rows![j] : null;
                  if (oldRow?.localPath != null && oldRow?.pictogram == row.pictogram) {
                    row.localPath = oldRow!.localPath;
                    continue;
                  }
                  imageTasks.add(() async {
                    final filename = _generateFilename(row.pictogram!, 'quick_access');
                    row.localPath = await _saveImageLocally(row.pictogram!, filename);
                  }());
                }
              }
            }
            break;

          case 'news':
            if (section.news?.displayMode == '1' && section.news?.newsRepeater != null) {
              for (int j = 0; j < section.news!.newsRepeater!.length; j++) {
                final repeater = section.news!.newsRepeater![j];
                if (repeater.repPictoImg != null) {
                  final oldRepeater = (oldSection?.news?.newsRepeater?.length ?? 0) > j ? oldSection?.news?.newsRepeater![j] : null;
                  if (oldRepeater?.localPath != null && oldRepeater?.repPictoImg == repeater.repPictoImg) {
                    repeater.localPath = oldRepeater!.localPath;
                    continue;
                  }
                  imageTasks.add(() async {
                    final filename = _generateFilename(repeater.repPictoImg!, 'news');
                    repeater.localPath = await _saveImageLocally(repeater.repPictoImg!, filename);
                  }());
                }
              }
            }
            break;

          case 'event':
            if (section.event?.displayMode == '1' && section.event?.eventRepeater != null) {
              for (int j = 0; j < section.event!.eventRepeater!.length; j++) {
                final repeater = section.event!.eventRepeater![j];
                if (repeater.repPictoImg != null) {
                  final oldRepeater = (oldSection?.event?.eventRepeater?.length ?? 0) > j ? oldSection?.event?.eventRepeater![j] : null;
                  if (oldRepeater?.localPath != null && oldRepeater?.repPictoImg == repeater.repPictoImg) {
                    repeater.localPath = oldRepeater!.localPath;
                    continue;
                  }
                  imageTasks.add(() async {
                    final filename = _generateFilename(repeater.repPictoImg!, 'event');
                    repeater.localPath = await _saveImageLocally(repeater.repPictoImg!, filename);
                  }());
                }
              }
            }
            break;

          case 'publication':
            if (section.publication?.displayMode == '1' && section.publication?.publicationRepeater != null) {
              for (int j = 0; j < section.publication!.publicationRepeater!.length; j++) {
                final repeater = section.publication!.publicationRepeater![j];
                if (repeater.repPictoImg != null) {
                  final oldRepeater = (oldSection?.publication?.publicationRepeater?.length ?? 0) > j ? oldSection?.publication?.publicationRepeater![j] : null;
                  if (oldRepeater?.localPath != null && oldRepeater?.repPictoImg == repeater.repPictoImg) {
                    repeater.localPath = oldRepeater!.localPath;
                    continue;
                  }
                  imageTasks.add(() async {
                    final filename = _generateFilename(repeater.repPictoImg!, 'publication');
                    repeater.localPath = await _saveImageLocally(repeater.repPictoImg!, filename);
                  }());
                }
              }
            }
            break;
        }
      }

      if (imageTasks.isNotEmpty) {
        debugPrint('⚡ Sauvegarde de ${imageTasks.length} images en parallèle...');
        await Future.wait(imageTasks);
        debugPrint('✅ ${imageTasks.length} images sauvegardées');
      }
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde images: $e');
    }
  }

  Future<void> _deleteObsoleteImages(BuildPage oldData, BuildPage newData) async {
    try {
      final oldSections = oldData.sections ?? [];
      final newSections = newData.sections ?? [];

      for (int i = 0; i < oldSections.length; i++) {
        final oldSection = oldSections[i];
        final Section? newSection = newSections.length > i ? newSections[i] : null;
        final String type = oldSection.type ?? '';

        switch (type) {
          case 'carousel':
            for (final repeater in oldSection.carrousel?.carrouselRepeater ?? []) {
              if (repeater.localPath != null) {
                final stillUsed = newSection?.carrousel?.carrouselRepeater?.any((r) => r.localPath == repeater.localPath) ?? false;
                if (!stillUsed) await _deleteImageFile(repeater.localPath!);
              }
            }
            break;
          case 'quick_access':
            for (final row in oldSection.quickAccess?.rows ?? []) {
              if (row.localPath != null) {
                final stillUsed = newSection?.quickAccess?.rows?.any((r) => r.localPath == row.localPath) ?? false;
                if (!stillUsed) await _deleteImageFile(row.localPath!);
              }
            }
            break;
          case 'news':
            for (final repeater in oldSection.news?.newsRepeater ?? []) {
              if (repeater.localPath != null) {
                final stillUsed = newSection?.news?.newsRepeater?.any((r) => r.localPath == repeater.localPath) ?? false;
                if (!stillUsed) await _deleteImageFile(repeater.localPath!);
              }
            }
            if (oldSection.news?.fluxXmlRSSChannel != null) {
              await _deleteRSSItemsImages(oldSection.news!.fluxXmlRSSChannel!, 'news');
            }
            break;
          case 'event':
            for (final repeater in oldSection.event?.eventRepeater ?? []) {
              if (repeater.localPath != null) {
                final stillUsed = newSection?.event?.eventRepeater?.any((r) => r.localPath == repeater.localPath) ?? false;
                if (!stillUsed) await _deleteImageFile(repeater.localPath!);
              }
            }
            if (oldSection.event?.fluxXmlRSSChannel != null) {
              await _deleteRSSItemsImages(oldSection.event!.fluxXmlRSSChannel!, 'event');
            }
            break;
          case 'publication':
            for (final repeater in oldSection.publication?.publicationRepeater ?? []) {
              if (repeater.localPath != null) {
                final stillUsed = newSection?.publication?.publicationRepeater?.any((r) => r.localPath == repeater.localPath) ?? false;
                if (!stillUsed) await _deleteImageFile(repeater.localPath!);
              }
            }
            if (oldSection.publication?.fluxXmlRSSChannel != null) {
              await _deleteRSSItemsImages(
                oldSection.publication!.fluxXmlRSSChannel!,
                'publication',
              );
            }
            break;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur suppression images obsolètes: $e');
    }
  }

  Future<void> _fetchAndIntegrateAllRSSFeeds(BuildPage buildPage) async {
    try {
      debugPrint('📡 Récupération et intégration des flux RSS...');
      final List<Section> sections = buildPage.sections ?? [];

      final List<Future<void>> rssTasks = [];

      for (int i = 0; i < sections.length; i++) {
        final Section section = sections[i];
        final String type = section.type ?? '';

        switch (type) {
          case 'event':
            if (section.event?.displayMode == '2' && section.event?.flux?.fluxLink != null) {
              rssTasks.add(() async {
                final eventChannel = await _fetchRSSFeed(
                  section.event!.flux!.fluxLink!,
                  'event',
                  int.parse(section.event!.flux!.numberElement ?? '0'),
                );
                if (eventChannel != null) {
                  final updateEvent = section.event!.copyWith(fluxXmlRSSChannel: eventChannel);
                  sections[i] = sections[i].copyWith(event: updateEvent);
                }
              }());
            }
            break;
          case 'news':
            if (section.news?.displayMode == '2' && section.news?.flux?.fluxLink != null) {
              rssTasks.add(() async {
                final newsChannel = await _fetchRSSFeed(
                  section.news!.flux!.fluxLink!,
                  'news',
                  int.parse(section.news!.flux!.numberElement ?? '0'),
                );
                if (newsChannel != null) {
                  final updateNews = section.news!.copyWith(fluxXmlRSSChannel: newsChannel);
                  sections[i] = sections[i].copyWith(news: updateNews);
                }
              }());
            }
            break;
          case 'publication':
            if (section.publication?.displayMode == '2' && section.publication?.flux?.fluxLink != null) {
              rssTasks.add(() async {
                final publicationChannel = await _fetchRSSFeed(
                  section.publication!.flux!.fluxLink!,
                  'publication',
                  int.parse(section.publication!.flux!.numberElement ?? '0'),
                );
                if (publicationChannel != null) {
                  final updatePublication = section.publication!.copyWith(fluxXmlRSSChannel: publicationChannel);
                  sections[i] = sections[i].copyWith(publication: updatePublication);
                }
              }());
            }
            break;
        }
      }

      if (rssTasks.isNotEmpty) {
        await Future.wait(rssTasks);
        debugPrint('✅ Tous les flux RSS intégrés (${rssTasks.length} feeds en parallèle)');
      }
    } catch (e) {
      debugPrint("⚠️ Erreur lors de l'intégration des flux RSS: $e");
    }
  }

  Future<FluxXmlRSSChannel?> _fetchRSSFeed(
    String url,
    String type,
    int numberElement,
  ) async {
    try {
      final result = await _fluxRSSService.fetchRSSFeed(url);
      return result.fold(
        (error) {
          debugPrint('⚠️ Erreur flux $type: $error');
          return null;
        },
        (channel) async {
          final limitedItems = channel.items.take(numberElement).toList();
          final limitedChannel = channel.copyWith(items: limitedItems);
          await _saveRSSItemsImages(limitedChannel, type);
          return limitedChannel;
        },
      );
    } catch (e) {
      debugPrint('⚠️ Erreur récupération flux $type: $e');
      return null;
    }
  }

  Future<void> _saveRSSItemsImages(FluxXmlRSSChannel channel, String type) async {
    try {
      final imageTasks = <Future<void>>[];
      for (int i = 0; i < channel.items.length; i++) {
        final item = channel.items[i];
        if (item.mainImage != null && item.mainImage!.isNotEmpty) {
          imageTasks.add(() async {
            final filename = _generateRSSImageFilename(item.mainImage!, type, i);
            final localPath = await _saveImageLocally(item.mainImage!, filename);
            if (localPath != null) {
              channel.items[i] = item.copyWith(localPath: localPath);
            }
          }());
        }
      }
      if (imageTasks.isNotEmpty) await Future.wait(imageTasks);
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde images RSS $type: $e');
    }
  }

  String _generateRSSImageFilename(String imageUrl, String type, int index) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _getImageExtension(imageUrl);
    return 'rss_${type}_${index}_$timestamp$extension';
  }

  Future<void> _deleteRSSItemsImages(FluxXmlRSSChannel channel, String type) async {
    try {
      for (final item in channel.items) {
        if (item.localPath != null && item.localPath!.contains('app_documents')) {
          await _deleteImageFile(item.localPath!);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur suppression images RSS $type: $e');
    }
  }

  Future<void> _deleteImageFile(String localPath) async {
    try {
      final success = await _imageService.deleteLocalImage(localPath);
      if (!success) debugPrint('⚠️ Impossible de supprimer: $localPath');
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
    if (imageUrl.contains('.jpg') || imageUrl.contains('.jpeg')) return '.jpg';
    if (imageUrl.contains('.png')) return '.png';
    if (imageUrl.contains('.gif')) return '.gif';
    if (imageUrl.contains('.webp')) return '.webp';
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
      return null;
    }
  }

  Future<void> _verifyLocalImages(int idProject, BuildPage buildPage) async {
    try {
      final List<Section> sections = buildPage.sections ?? [];
      bool hasChanges = false;
      for (int i = 0; i < sections.length; i++) {
        final Section section = sections[i];
        final String type = section.type ?? '';
        switch (type) {
          case 'carousel':
            for (var repeater in section.carrousel?.carrouselRepeater ?? []) {
              if (repeater.localPath != null) {
                if (!await _imageService.imageExistsLocally(repeater.localPath!)) {
                  repeater.localPath = null;
                  hasChanges = true;
                }
              }
            }
            break;
          case 'quick_access':
            for (var row in section.quickAccess?.rows ?? []) {
              if (row.localPath != null) {
                if (!await _imageService.imageExistsLocally(row.localPath!)) {
                  row.localPath = null;
                  hasChanges = true;
                }
              }
            }
            break;
          case 'news':
            for (var repeater in section.news?.newsRepeater ?? []) {
              if (repeater.localPath != null) {
                if (!await _imageService.imageExistsLocally(repeater.localPath!)) {
                  repeater.localPath = null;
                  hasChanges = true;
                }
              }
            }
            if (section.news?.fluxXmlRSSChannel != null) {
              hasChanges = await _verifyRSSItemsImages(section.news!.fluxXmlRSSChannel!) || hasChanges;
            }
            break;
          case 'event':
            for (var repeater in section.event?.eventRepeater ?? []) {
              if (repeater.localPath != null) {
                if (!await _imageService.imageExistsLocally(repeater.localPath!)) {
                  repeater.localPath = null;
                  hasChanges = true;
                }
              }
            }
            if (section.event?.fluxXmlRSSChannel != null) {
              hasChanges = await _verifyRSSItemsImages(section.event!.fluxXmlRSSChannel!) || hasChanges;
            }
            break;
          case 'publication':
            for (var repeater in section.publication?.publicationRepeater ?? []) {
              if (repeater.localPath != null) {
                if (!await _imageService.imageExistsLocally(repeater.localPath!)) {
                  repeater.localPath = null;
                  hasChanges = true;
                }
              }
            }
            if (section.publication?.fluxXmlRSSChannel != null) {
              hasChanges = await _verifyRSSItemsImages(section.publication!.fluxXmlRSSChannel!) || hasChanges;
            }
            break;
        }
      }
      if (hasChanges) await _saveToLocalStorage(idProject, buildPage);
    } catch (e) {
      debugPrint('⚠️ Erreur vérification images: $e');
    }
  }

  Future<bool> _verifyRSSItemsImages(FluxXmlRSSChannel channel) async {
    bool hasChanges = false;
    try {
      for (int i = 0; i < channel.items.length; i++) {
        final item = channel.items[i];
        if (item.localPath != null) {
          if (!await _imageService.imageExistsLocally(item.localPath!)) {
            hasChanges = true;
            channel.items[i] = item.copyWith();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur vérification images RSS: $e');
    }
    return hasChanges;
  }

  Future<void> _saveToLocalStorage(int idProject, BuildPage buildPage) async {
    try {
      await _buildPageStorage.save(idProject.toString(), buildPage);
      debugPrint('💾 BuildPage sauvegardée');
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde BuildPage: $e');
    }
  }
}
