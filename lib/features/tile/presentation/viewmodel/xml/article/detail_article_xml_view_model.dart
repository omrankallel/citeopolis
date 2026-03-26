import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../favorites/domain/factories/favorite_factory.dart';
import '../../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_article.dart';
import 'articles_xml_view_model.dart';

final detailArticleXmlProvider = ChangeNotifierProvider.autoDispose((ref) => DetailArticleXmlProvider());

class DetailArticleXmlProvider extends ChangeNotifier {
  bool isInitialized = false;
  String favoriteButtonTag = '';

  final searchController = TextEditingController();

  bool isEmpty = false;

  final isFavorite = StateProvider<bool>((ref) => false);
  final allArticles = StateProvider<List<Article>>((ref) => []);
  final fieldsConfiguration = StateProvider<List<TileXmlId>>((ref) => []);

  List<TileXmlId> orderedFieldsListItem = [];

  List<TileXmlId> orderedFieldsSingleList = [];

  Future<void> initArticlesXml(WidgetRef ref, TileXml tileXml, List<Article>? allArticles, Article article) async {
    if (!isInitialized) {
      isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!ref.context.mounted) return;
        favoriteButtonTag = '${tileXml.results?.urlTile ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}';
        searchController.clear();

        orderedFieldsListItem.clear();

        final fieldsListItem = getVisibleOrderItems(tileXml.results?.idsList);
        orderedFieldsListItem = fieldsListItem;

        ref.read(isFavorite.notifier).state = isFavoriteArticle(ref, tileXml.id ?? '0', article);

        await loadRecommendedArticles(ref, tileXml, allArticles);
        if (!ref.context.mounted) return;
        notifyListeners();
      });
    }
  }

  Future<void> loadRecommendedArticles(WidgetRef ref, TileXml tileXml, List<Article>? allArticles) async {
    if (allArticles != null && allArticles.isNotEmpty) {
      setAllArticles(allArticles, ref);
      final fieldsConfig = ref.read(articlesXmlProvider).orderedFieldsSingleList;
      if (fieldsConfig.isNotEmpty) {
        setFieldsConfiguration(fieldsConfig, ref);
      }
    } else {
        final articles = await ref.read(configProvider(tileXml).future);
        if (!ref.context.mounted) return;

        setAllArticles(articles, ref);
        final fieldsConfig = orderedFieldsSingleList;
        setFieldsConfiguration(fieldsConfig, ref);

    }
  }

  final configProvider = FutureProvider.family.autoDispose<List<Article>, TileXml>((ref, tileXml) async {
    try {
      final detailArticleXmlViewModel = ref.read(detailArticleXmlProvider);

      final url = tileXml.results?.urlTile ?? '';
      final numberElement = int.parse(tileXml.results?.numberElement ?? '0');

      if (url.isEmpty) return [];

      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlArticles = <XmlElement>[];
        for (final articleNode in document.findAllElements('article')) {
          allXmlArticles.add(articleNode);
        }

        final config = tileXml.results;

        final fieldsSingleList = detailArticleXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        detailArticleXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isEmpty) {
          return [];
        }

        final List<Article> listArticles = [];
        listArticles.addAll(allXmlArticles.map((xmlElement) => Article.fromXml(xmlElement)).toList());

        return listArticles.take(numberElement).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      return [];
    }
  });

  void setAllArticles(List<Article> articles, WidgetRef ref) {
    ref.read(allArticles.notifier).state = articles;
  }

  void setFieldsConfiguration(List<TileXmlId> fields, WidgetRef ref) {
    ref.read(fieldsConfiguration.notifier).state = fields;
  }

  List<Article> getRecommendedArticles(Article currentArticle, WidgetRef ref) {
    final articles = ref.read(allArticles);
    return articles.where((article) => article.title != currentArticle.title).toList();
  }

  List<TileXmlId> getVisibleOrderItems(List<TileXmlId>? idsList) => idsList?.where((field) => field.status == 1).toList() ?? [];

  String generateFavoriteId(String tileXmlId, Article article) => 'tile_xml_${tileXmlId}_${article.title.hashCode}';

  bool isFavoriteArticle(WidgetRef ref, String tileXmlId, Article article) {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = generateFavoriteId(tileXmlId, article);
    return useCase.isFavorite(favoriteId);
  }

  Future<void> onPressFavorite(WidgetRef ref, TileXml tileXml, Article currentArticle) async {
    if (!ref.context.mounted) return;

    final useCase = ref.read(favoriteUseCaseProvider);
    final tileXmlId = tileXml.id ?? '0';
    final favoriteId = generateFavoriteId(tileXmlId, currentArticle);

    final favorite = FavoriteFactory.fromArticleXml(tileXml, currentArticle);
    favorite.id = favoriteId;
    favorite.title = currentArticle.title;
    favorite.imageUrl = currentArticle.mainImage;

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

  Future<void> onSearchTextChanged(WidgetRef ref, Article article, String search) async {
    if (search.isEmpty) {
      isEmpty = false;
      notifyListeners();
      return;
    }

    final searchLower = search.toLowerCase();
    final searchTerms = searchLower.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      article.title,
      article.category,
      article.summary,
      article.content,
      article.imageCaption,
      article.mainImage,
      article.pubDate,
      article.updateDate,
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == article.content) {
          fieldContent = cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == article.mainImage && field.isNotEmpty) {
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
