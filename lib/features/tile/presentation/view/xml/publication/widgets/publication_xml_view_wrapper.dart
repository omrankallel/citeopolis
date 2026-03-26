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
import '../../../../../domain/modals/xml/xml_publication.dart';
import '../../../../viewmodel/xml/publication/publications_xml_view_model.dart';

class PublicationXmlViewWrapper extends StatelessWidget {
  final bool withScaffold;
  final TileXml tileXml;

  const PublicationXmlViewWrapper({
    required this.tileXml,
    required this.withScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final publicationsXmlViewModel = ref.watch(publicationsXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          publicationsXmlViewModel.initializePublications(ref, tileXml, withScaffold);
          return withScaffold ? _buildWithScaffold(ref, isDarkMode, context) : _buildWithoutScaffold(ref, isDarkMode, context);
        },
      );

  Widget _buildWithScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final publicationsXmlViewModel = ref.watch(publicationsXmlProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: publicationsXmlViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawerEnableOpenDragGesture: false,
        endDrawer: publicationsXmlViewModel.atomEndDrawerPublication(ref, publicationsXmlViewModel.scaffoldKey, isDarkMode),
        appBar: AtomAppBarWithSearch(
          searchController: publicationsXmlViewModel.searchController,
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
          onSearchChanged: (text) => publicationsXmlViewModel.onSearchTextChanged(ref, text),
          onSearchCleared: () => publicationsXmlViewModel.onSearchTextChanged(ref, ''),
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
            _buildHeader(ref, publicationsXmlViewModel.scaffoldKey, isDarkMode, context),
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
              text: 'Publications',
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
    final publicationsXmlViewModel = ref.watch(publicationsXmlProvider);
    final filteredPublications = ref.watch(publicationsXmlViewModel.publicationsFiltered);
    final orderedFields = publicationsXmlViewModel.orderedFieldsSingleList;

    final searchText = withScaffold ? publicationsXmlViewModel.searchController.text : ref.watch(homeProvider).searchController.text;

    return ref.watch(publicationsXmlViewModel.configProviderFamily(tileXml)).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFCA542B)),
          ),
          data: (_) => orderedFields.isEmpty
              ? const SizedBox()
              : filteredPublications.isEmpty && publicationsXmlViewModel.hasActiveSearch(searchText)
                  ? AtomNoResult(
                      isDarkMode: isDarkMode,
                      query: searchText,
                      text: 'Publication',
                    )
                  : _buildPublicationsList(ref, filteredPublications, searchText, isDarkMode),
          error: (error, _) => Center(
            child: Text(
              'Erreur : $error',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
  }

  Widget _buildPublicationsList(WidgetRef ref, List<Publication> filteredPublications, String searchText, bool isDarkMode) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                itemCount: filteredPublications.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final publication = filteredPublications[index];
                  return _buildPublicationCard(context, ref, publication, searchText, isDarkMode);
                },
                separatorBuilder: (context, index) => 32.ph,
              ),
              50.ph,
            ],
          ),
        ),
      );

  Widget _buildPublicationCard(BuildContext context, WidgetRef ref, Publication publication, String searchText, bool isDarkMode) {
    final publicationsXmlViewModel = ref.watch(publicationsXmlProvider);

    return InkWell(
      onTap: () {
        NavigationService.push(
          context,
          ref,
          Paths.detailPublicationXml,
          extra: {
            'tileXml': tileXml,
            'publicationXml': publication,
            'allPublications': publicationsXmlViewModel.publications,
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
          children: _buildPublicationFields(context, ref, publication, isDarkMode, searchText),
        ),
      ),
    );
  }

  List<Widget> _buildPublicationFields(BuildContext context, WidgetRef ref, Publication publication, bool isDarkMode, String searchText) {
    final publicationsXmlViewModel = ref.watch(publicationsXmlProvider);
    final orderedFields = publicationsXmlViewModel.orderedFieldsSingleList;

    String title = '';
    String category = '';
    String mainImage = '';
    int imageIndex = -1;
    int titleIndex = -1;
    int categoryIndex = -1;

    for (int i = 0; i < orderedFields.length; i++) {
      final fieldTag = (orderedFields[i].balise ?? '').toLowerCase();
      switch (fieldTag) {
        case 'title':
          title = publication.title;
          titleIndex = i;
          break;
        case 'category':
          category = publication.category;
          categoryIndex = i;
          break;
        case 'mainimage':
          mainImage = publication.mainImage;
          imageIndex = i;
          break;
      }
    }

    if (mainImage.isEmpty) {
      final widgets = <Widget>[];
      for (final field in orderedFields) {
        final fieldTag = (field.balise ?? '').toLowerCase();
        if (fieldTag == 'title' && title.isNotEmpty) {
          widgets.addAll([
            AtomHighlightedText(
              text: title,
              searchQuery: searchText,
              style: Theme.of(context).textTheme.titleLarge!,
              isDarkMode: isDarkMode,
              maxLines: 3,
            ),
            15.ph,
          ]);
        } else if (fieldTag == 'category' && category.isNotEmpty) {
          widgets.addAll([
            AtomHighlightedText(
              text: category,
              searchQuery: searchText,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: isDarkMode ? primaryDark : primaryLight,
                  ),
              isDarkMode: isDarkMode,
            ),
            15.ph,
          ]);
        }
      }
      return widgets;
    }

    final textIndices = [titleIndex, categoryIndex].where((index) => index != -1).toList();

    final firstTextIndex = textIndices.reduce((a, b) => a < b ? a : b);

    final imageBeforeTexts = imageIndex < firstTextIndex;

    final textWidgets = <Widget>[];
    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();
      if (fieldTag == 'title' && title.isNotEmpty) {
        textWidgets.addAll([
          AtomHighlightedText(
            text: publication.title,
            searchQuery: searchText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                ),
            isDarkMode: isDarkMode,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          8.ph,
        ]);
      } else if (fieldTag == 'category' && category.isNotEmpty) {
        textWidgets.addAll([
          AtomHighlightedText(
            text: publication.category,
            searchQuery: searchText,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: isDarkMode ? primaryDark : primaryLight,
                ),
            isDarkMode: isDarkMode,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          8.ph,
        ]);
      }
    }

    if (textWidgets.isNotEmpty) {
      textWidgets.removeLast();
    }

    final imageWidget = Material(
      elevation: 4,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AtomUploadImage(
          base64ImageData: mainImage,
          fit: BoxFit.cover,
          width: Helpers.getResponsiveWidth(context) * .3,
          height: 150,
        ),
      ),
    );

    final rowChildren = <Widget>[];

    if (imageBeforeTexts) {
      rowChildren.addAll([
        imageWidget,
        16.pw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: textWidgets,
          ),
        ),
      ]);
    } else {
      rowChildren.addAll([
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: textWidgets,
          ),
        ),
        16.pw,
        imageWidget,
      ]);
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowChildren,
      ),
    ];
  }
}
