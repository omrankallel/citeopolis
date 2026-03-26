import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../favorites/domain/factories/favorite_factory.dart';
import '../../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_publication.dart';
import 'publications_xml_view_model.dart';

final detailPublicationXmlProvider = ChangeNotifierProvider.autoDispose((ref) => DetailPublicationXmlProvider());

class DetailPublicationXmlProvider extends ChangeNotifier {
  bool isInitialized = false;
  String favoriteButtonTag = '';

  final searchController = TextEditingController();

  bool isEmpty = false;

  final isFavorite = StateProvider<bool>((ref) => false);
  final allPublications = StateProvider<List<Publication>>((ref) => []);
  final fieldsConfiguration = StateProvider<List<TileXmlId>>((ref) => []);

  List<TileXmlId> orderedFieldsListItem = [];

  List<TileXmlId> orderedFieldsSingleList = [];

  Future<void> initPublicationsXml(WidgetRef ref, TileXml tileXml, List<Publication>? allPublications, Publication publication) async {
    if (!isInitialized) {
      isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!ref.context.mounted) return;
        favoriteButtonTag = '${tileXml.results?.urlTile ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}';
        searchController.clear();

        orderedFieldsListItem.clear();

        final fieldsListItem = getVisibleOrderItems(tileXml.results?.idsList);
        orderedFieldsListItem = fieldsListItem;

        ref.read(isFavorite.notifier).state = isFavoritePublication(ref, tileXml.id ?? '0', publication);

        await loadRecommendedPublications(ref, tileXml, allPublications);
        if (!ref.context.mounted) return;
        notifyListeners();
      });
    }
  }

  Future<void> loadRecommendedPublications(WidgetRef ref, TileXml tileXml, List<Publication>? allPublications) async {
    if (allPublications != null && allPublications.isNotEmpty) {
      setAllPublications(allPublications, ref);
      final fieldsConfig = ref.read(publicationsXmlProvider).orderedFieldsSingleList;
      if (fieldsConfig.isNotEmpty) {
        setFieldsConfiguration(fieldsConfig, ref);
      }
    } else {
      final publications = await ref.read(configProvider(tileXml).future);
      if (!ref.context.mounted) return;

      setAllPublications(publications, ref);
      final fieldsConfig = orderedFieldsSingleList;
      setFieldsConfiguration(fieldsConfig, ref);
    }
  }

  final configProvider = FutureProvider.family.autoDispose<List<Publication>, TileXml>((ref, tileXml) async {
    try {
      final detailPublicationXmlViewModel = ref.read(detailPublicationXmlProvider);

      final url = tileXml.results?.urlTile ?? '';
      final numberElement = int.parse(tileXml.results?.numberElement ?? '0');

      if (url.isEmpty) return [];

      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlPublications = <XmlElement>[];
        for (final publicationNode in document.findAllElements('publication')) {
          allXmlPublications.add(publicationNode);
        }

        final config = tileXml.results;

        final fieldsSingleList = detailPublicationXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        detailPublicationXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isEmpty) {
          return [];
        }

        final List<Publication> listPublications = [];
        listPublications.addAll(allXmlPublications.map((xmlElement) => Publication.fromXml(xmlElement)).toList());

        return listPublications.take(numberElement).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching publications: $e');
      return [];
    }
  });

  void setAllPublications(List<Publication> publications, WidgetRef ref) {
    ref.read(allPublications.notifier).state = publications;
  }

  void setFieldsConfiguration(List<TileXmlId> fields, WidgetRef ref) {
    ref.read(fieldsConfiguration.notifier).state = fields;
  }

  List<Publication> getRecommendedPublications(Publication currentPublication, WidgetRef ref) {
    final publications = ref.read(allPublications);
    return publications.where((publication) => publication.title != currentPublication.title).toList();
  }

  List<TileXmlId> getVisibleOrderItems(List<TileXmlId>? idsList) => idsList?.where((field) => field.status == 1).toList() ?? [];

  String generateFavoriteId(String tileXmlId, Publication publication) => 'tile_xml_${tileXmlId}_${publication.title.hashCode}';

  bool isFavoritePublication(WidgetRef ref, String tileXmlId, Publication publication) {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = generateFavoriteId(tileXmlId, publication);
    return useCase.isFavorite(favoriteId);
  }

  Future<void> onPressFavorite(WidgetRef ref, TileXml tileXml, Publication currentPublication) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final tileXmlId = tileXml.id ?? '0';
    final favoriteId = generateFavoriteId(tileXmlId, currentPublication);

    final favorite = FavoriteFactory.fromPublicationXml(tileXml, currentPublication);
    favorite.id = favoriteId;
    favorite.title = currentPublication.title;
    favorite.imageUrl = currentPublication.mainImage;

    final currentIsFavorite = ref.read(isFavorite);
    ref.read(isFavorite.notifier).state = !currentIsFavorite;

    try {
      final result = currentIsFavorite ? await useCase.removeFromFavorites(favorite.id) : await useCase.addToFavorites(favorite);

      result.fold(
        (error) {
          ref.read(isFavorite.notifier).state = currentIsFavorite;
          Helpers.showSnackBar(ref.context, 'Erreur: $error', Colors.red);
        },
        (success) {
          ref.read(updateFavorites.notifier).state = !ref.read(updateFavorites);
          final message = !currentIsFavorite ? 'Ajouté aux favoris' : 'Supprimé des favoris';
          Helpers.showSnackBar(ref.context, message, Colors.green);
        },
      );
    } catch (e) {
      ref.read(isFavorite.notifier).state = currentIsFavorite;
      if (ref.context.mounted) {
        Helpers.showSnackBar(ref.context, 'Erreur inattendue: $e', Colors.red);
      }
    }
  }

  Future<void> onSearchTextChanged(WidgetRef ref, Publication publication, String search) async {
    if (search.isEmpty) {
      isEmpty = false;
      notifyListeners();
      return;
    }

    final searchLower = search.toLowerCase();
    final searchTerms = searchLower.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      publication.title,
      publication.category,
      publication.summary,
      publication.content,
      publication.imageCaption,
      publication.mainImage,
      publication.pubDate,
      publication.updateDate,
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == publication.content) {
          fieldContent = cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == publication.mainImage && field.isNotEmpty) {
          final fileName = field.split('/').last.toLowerCase();
          final fileNameWithoutExtension = fileName.split('.').first;

          if (fileName.contains(term) || fileNameWithoutExtension.contains(term)) {
            termFound = true;
            break;
          }
        }
      }

      if (!termFound) {
        isEmpty = true;
        notifyListeners();
        return;
      }
    }

    isEmpty = false;
    notifyListeners();
  }

  String cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return '';
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'&\w+;'), ' ').trim().toLowerCase();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
