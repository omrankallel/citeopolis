import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../../../../router/navigation_service.dart';
import '../../../../../../../router/routes.dart';
import '../../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../../domain/modals/tile_xml.dart';
import '../../../../../domain/modals/xml/xml_article.dart';
import '../../../../viewmodel/xml/article/articles_xml_view_model.dart';

class ArticleXmlViewWrapper extends StatelessWidget {
  final bool withScaffold;
  final TileXml tileXml;

  const ArticleXmlViewWrapper({
    required this.tileXml,
    required this.withScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final articlesXmlViewModel = ref.watch(articlesXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          articlesXmlViewModel.initializeArticles(ref, tileXml,withScaffold);
          return withScaffold ? _buildWithScaffold(ref, isDarkMode, context) : _buildWithoutScaffold(ref, isDarkMode, context);
        },
      );

  Widget _buildWithScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final articlesXmlViewModel = ref.watch(articlesXmlProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: articlesXmlViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawerEnableOpenDragGesture: false,
        endDrawer: articlesXmlViewModel.atomEndDrawerArticle(ref, articlesXmlViewModel.scaffoldKey, isDarkMode),
        appBar: AtomAppBarWithSearch(
          searchController: articlesXmlViewModel.searchController,
          isDarkMode: isDarkMode,
          searchHint: 'Rechercher ...',
          backgroundColor: Theme.of(context).primaryColor,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => NavigationService.back(context, ref),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
              ),
            ),
          ),
          onSearchChanged: (text) => articlesXmlViewModel.onSearchTextChanged(ref, text),
          onSearchCleared: () => articlesXmlViewModel.onSearchTextChanged(ref, ''),
          actions: [
            NotificationIconBadge(
              iconData: Icons.notifications_none_sharp,
              onTap: () => NavigationService.push(context, ref, Paths.notifications),
            ),
            25.pw,
            InkWell(
              onTap: () {},
              child: const WidgetPopupMenu(),
            ),
            20.pw,
          ],
        ),
        body: Column(
          children: [
            20.ph,
            _buildHeader(ref, articlesXmlViewModel.scaffoldKey, isDarkMode, context),
            26.ph,
            Expanded(child: _buildContent(ref, isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildWithoutScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final homeViewModel = ref.watch(homeProvider);
    return Column(
      children: [
        20.ph,
        _buildHeader(ref, homeViewModel.scaffoldKey, isDarkMode, context),
        26.ph,
        Expanded(child: _buildContent(ref, isDarkMode)),
      ],
    );
  }


  Widget _buildHeader(WidgetRef ref, GlobalKey<ScaffoldState> scaffoldKey, bool isDarkMode, BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            AtomHighlightedText(
              text: 'Actualités',
              searchQuery: '',
              style: Theme.of(context).textTheme.headlineLarge!,
              isDarkMode: isDarkMode,
            ),
            const Spacer(),
            InkWell(
              onTap: () => scaffoldKey.currentState?.openEndDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFF757579)),
                ),
                child: AtomTextIcon(
                  data: 'Filtrer',
                  iconData: Icons.sort,
                  spacing: 8,
                  style: Theme.of(context).textTheme.labelLarge,
                  sizeIcon: 18,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildContent(WidgetRef ref, bool isDarkMode) {
    final articlesXmlViewModel = ref.watch(articlesXmlProvider);
    final filteredArticles = ref.watch(articlesXmlViewModel.articlesFiltered);
    final orderedFields = articlesXmlViewModel.orderedFieldsSingleList;

    final searchText = withScaffold ? articlesXmlViewModel.searchController.text : ref.watch(homeProvider).searchController.text;

    return ref.watch(articlesXmlViewModel.configProviderFamily(tileXml)).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFCA542B)),
          ),
          data: (_) => orderedFields.isEmpty
              ? const SizedBox()
              : filteredArticles.isEmpty && articlesXmlViewModel.hasActiveSearch(searchText)
                  ? AtomNoResult(
                      isDarkMode: isDarkMode,
                      query: searchText,
                      text: 'Article',
                    )
                  : _buildArticlesList(ref, filteredArticles, searchText, isDarkMode),
          error: (error, _) => Center(
            child: Text(
              'Erreur : $error',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
  }

  Widget _buildArticlesList(WidgetRef ref, List<Article> filteredArticles, String searchText, bool isDarkMode) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                itemCount: filteredArticles.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return _buildArticleCard(context, ref, article, searchText, isDarkMode);
                },
                separatorBuilder: (context, index) => 32.ph,
              ),
              50.ph,
            ],
          ),
        ),
      );

  Widget _buildArticleCard(BuildContext context, WidgetRef ref, Article article, String searchText, bool isDarkMode) {
    final articlesXmlViewModel = ref.watch(articlesXmlProvider);

    return InkWell(
      onTap: () {
        NavigationService.push(
          context,
          ref,
          Paths.detailArticleXml,
          extra: {
            'tileXml': tileXml,
            'articleXml': article,
            'allArticles': articlesXmlViewModel.articles,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
          boxShadow: [
            const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 23.2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildArticleFields(context, ref, article, isDarkMode, searchText),
        ),
      ),
    );
  }

  List<Widget> _buildArticleFields(BuildContext context, WidgetRef ref, Article article, bool isDarkMode, String searchText) {
    final articlesXmlViewModel = ref.watch(articlesXmlProvider);
    final orderedFields = articlesXmlViewModel.orderedFieldsSingleList;
    final widgets = <Widget>[];

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (article.title.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: article.title,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleLarge!,
                isDarkMode: isDarkMode,
                maxLines: 3,
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
                  child: AtomUploadImage(
                    base64ImageData: article.mainImage,
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
              AtomHighlightedText(
                text: article.category,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!,
                isDarkMode: isDarkMode,
              ),
              15.ph,
            ]);
          }
          break;
      }
    }

    return widgets;
  }
}
