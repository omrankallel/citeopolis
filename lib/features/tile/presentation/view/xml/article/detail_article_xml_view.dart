import 'package:badges/badges.dart' as bg;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../../../design_system/atoms/atom_floating_action_button_favorite.dart';
import '../../../../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../design_system/atoms/atom_text.dart';
import '../../../../../../../router/routes.dart';
import '../../../../../../router/navigation_service.dart';
import '../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_article.dart';
import '../../../viewmodel/xml/article/articles_xml_view_model.dart';
import '../../../viewmodel/xml/article/detail_article_xml_view_model.dart';

class DetailArticleXmlView extends StatelessWidget {
  final TileXml tileXml;
  final Article article;
  final List<Article>? allArticles;

  const DetailArticleXmlView({
    required this.tileXml,
    required this.article,
    this.allArticles,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final detailArticleXmlViewModel = ref.watch(detailArticleXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;

          detailArticleXmlViewModel.initArticlesXml(ref, tileXml, allArticles, article);
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawerEnableOpenDragGesture: false,
              appBar: AtomAppBarWithSearch(
                title: 'Actualités',
                isDarkMode: isDarkMode,
                searchController: detailArticleXmlViewModel.searchController,
                onSearchChanged: (text) => detailArticleXmlViewModel.onSearchTextChanged(ref, article, text),
                onSearchCleared: () => detailArticleXmlViewModel.onSearchTextChanged(ref, article, ''),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      detailArticleXmlViewModel.isInitialized = false;
                      detailArticleXmlViewModel.searchController.clear();
                      NavigationService.back(context, ref);
                    },
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
                actions: [
                  NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () {
                      detailArticleXmlViewModel.searchController.clear();
                      NavigationService.push(context, ref, Paths.notifications);
                    },
                  ),
                  25.pw,
                  InkWell(
                    onTap: () {},
                    child: const bg.Badge(
                      showBadge: false,
                      child: WidgetPopupMenu(),
                    ),
                  ),
                  20.pw,
                ],
              ),
              body: _buildContent(context, ref, isDarkMode),
              floatingActionButton: _buildFavoriteButton(ref, isDarkMode),
            ),
          );
        },
      );

  Widget _buildContent(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final detailArticleXmlViewModel = ref.watch(detailArticleXmlProvider);
    final orderedFields = detailArticleXmlViewModel.orderedFieldsListItem;

    final searchText = detailArticleXmlViewModel.searchController.text;
    final isEmpty = detailArticleXmlViewModel.isEmpty;

    return orderedFields.isEmpty
        ? const SizedBox()
        : isEmpty && searchText.isNotEmpty
            ? AtomNoResult(
                isDarkMode: isDarkMode,
                query: searchText,
                text: 'Article',
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildArticleContent(context, ref, isDarkMode, searchText),
                        ],
                      ),
                    ),
                    _buildRecommendedSection(context, ref, isDarkMode),
                  ],
                ),
              );
  }

  List<Widget> _buildArticleContent(BuildContext context, WidgetRef ref, bool isDarkMode, String searchText) {
    final detailArticleXmlViewModel = ref.watch(detailArticleXmlProvider);
    final orderedFields = detailArticleXmlViewModel.orderedFieldsListItem;

    final List<Widget> widgets = [];

    final List<String> dateParts = [];
    bool dateWidgetAdded = false;

    final dateFields = orderedFields.map((e) => (e.balise ?? '').toLowerCase()).where((b) => b == 'pubdate' || b == 'updatedate').toList();
    final String? lastDateField = dateFields.isNotEmpty ? dateFields.last : null;

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (article.title.isNotEmpty) {
            widgets.addAll([
              15.ph,
              AtomHighlightedText(
                text: article.title,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.headlineLarge!,
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'summary':
          if (article.summary.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: article.summary,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'mainimage':
          if (article.mainImage.isNotEmpty) {
            widgets.addAll([
              25.ph,
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: article.mainImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ]);
          }
          break;

        case 'imagecaption':
          if (article.imageCaption.isNotEmpty) {
            widgets.addAll([
              10.ph,
              AtomHighlightedText(
                text: article.imageCaption,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(letterSpacing: 0.5),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'content':
          if (article.content.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: article.content,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.labelSmall!,
                isDarkMode: isDarkMode,
                isHtml: true,
                overflow: TextOverflow.visible,
              ),
              25.ph,
            ]);
          }
          break;

        case 'category':
          if (article.category.isNotEmpty) {
            widgets.addAll([
              20.ph,
              AtomHighlightedText(
                text: article.category,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDarkMode ? primaryDark : primaryLight,
                    ),
                isDarkMode: isDarkMode,
                overflow: TextOverflow.visible,
              ),
              20.ph,
            ]);
          }
          break;

        ///date de publication
        case 'pubdate':
          if (article.pubDate.isNotEmpty) {
            dateParts.add('Publié le ${_formatDate(article.pubDate)}');
          }
          break;

        ///date de mise à jour
        case 'updatedate':
          if (article.updateDate.isNotEmpty) {
            dateParts.add('Mis à jour le ${_formatDate(article.updateDate)}');
          }
          break;
        default:
          break;
      }
      if (!dateWidgetAdded && fieldTag == lastDateField && dateParts.isNotEmpty) {
        widgets.addAll([
          25.ph,
          const Divider(),
          10.ph,
          AtomHighlightedText(
            text: dateParts.join(' - ').toUpperCase(),
            searchQuery: searchText,
            style: Theme.of(context).textTheme.labelSmall!,
            isDarkMode: isDarkMode,
          ),
          10.ph,
          const Divider(),
          25.ph,
        ]);

        dateWidgetAdded = true;
      }
    }

    return widgets;
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRecommendedSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final detailArticleXmlViewModel = ref.watch(detailArticleXmlProvider);
    final recommendedArticles = detailArticleXmlViewModel.getRecommendedArticles(article, ref);

    if (recommendedArticles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          50.ph,
          AtomText(
            data: 'À lire aussi...',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                ),
          ),
          20.ph,
          SizedBox(
            height: 325,
            child: ListView.separated(
              itemCount: recommendedArticles.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final article = recommendedArticles[index];
                final isLast = index == recommendedArticles.length - 1;
                if (isLast) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildRecommendedCard(context, ref, article, isDarkMode),
                  );
                }
                return _buildRecommendedCard(context, ref, article, isDarkMode);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
          80.ph,
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, WidgetRef ref, Article article, bool isDarkMode) => InkWell(
        onTap: () {
          final detailArticleXmlViewModel = ref.read(detailArticleXmlProvider);
          detailArticleXmlViewModel.isInitialized = false;
          detailArticleXmlViewModel.searchController.clear();
          NavigationService.push(
            context,
            ref,
            Paths.detailArticleXml,
            extra: {
              'tileXml': tileXml,
              'articleXml': article,
              'allArticles': allArticles,
            },
          );
        },
        child: SizedBox(
          width: Helpers.getResponsiveWidth(context) * .7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRecommendedCardContent(context, ref, article, isDarkMode),
          ),
        ),
      );

  List<Widget> _buildRecommendedCardContent(BuildContext context, WidgetRef ref, Article article, bool isDarkMode) {
    final detailViewModel = ref.read(detailArticleXmlProvider);
    final fieldsConfig = ref.watch(detailViewModel.fieldsConfiguration);
    final fieldsToUse = fieldsConfig.isNotEmpty ? fieldsConfig : ref.read(articlesXmlProvider).orderedFieldsSingleList;

    final widgets = <Widget>[];
    for (final field in fieldsToUse) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (article.title.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 80,
                child: AtomHighlightedText(
                  text: article.title,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleLarge!,
                  isDarkMode: isDarkMode,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'mainimage':
          if (article.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: article.mainImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'category':
          if (article.category.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 30,
                child: AtomHighlightedText(
                  text: article.category,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleMedium!,
                  isDarkMode: isDarkMode,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              15.ph,
            ]);
          } else {
            widgets.add(45.ph);
          }
          break;
      }
    }

    return widgets;
  }

  Widget _buildFavoriteButton(WidgetRef ref, bool isDarkMode) {
    final detailArticleXmlViewModel = ref.watch(detailArticleXmlProvider);
    final isFavorite = ref.watch(detailArticleXmlViewModel.isFavorite);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'articleXmlViewWrapper${detailArticleXmlViewModel.favoriteButtonTag}',
          onPressed: () => detailArticleXmlViewModel.onPressFavorite(ref, tileXml, article),
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
      ],
    );
  }
}
