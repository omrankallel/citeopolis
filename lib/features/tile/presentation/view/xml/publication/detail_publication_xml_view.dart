import 'package:badges/badges.dart' as bg;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../../../design_system/atoms/atom_floating_action_button_favorite.dart';
import '../../../../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../design_system/atoms/atom_text.dart';
import '../../../../../../../router/routes.dart';
import '../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_download_file.dart';
import '../../../../domain/modals/xml/xml_publication.dart';
import '../../../viewmodel/xml/publication/detail_publication_xml_view_model.dart';
import '../../../viewmodel/xml/publication/publications_xml_view_model.dart';

class DetailPublicationXmlView extends StatelessWidget {
  final TileXml tileXml;
  final Publication publication;
  final List<Publication>? allPublications;

  const DetailPublicationXmlView({
    required this.tileXml,
    required this.publication,
    this.allPublications,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final detailPublicationXmlViewModel = ref.watch(detailPublicationXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;

          detailPublicationXmlViewModel.initPublicationsXml(ref, tileXml, allPublications, publication);
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawerEnableOpenDragGesture: false,
              appBar: AtomAppBarWithSearch(
                title: 'Publications',
                isDarkMode: isDarkMode,
                searchController: detailPublicationXmlViewModel.searchController,
                onSearchChanged: (text) => detailPublicationXmlViewModel.onSearchTextChanged(ref, publication, text),
                onSearchCleared: () => detailPublicationXmlViewModel.onSearchTextChanged(ref, publication, ''),
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      detailPublicationXmlViewModel.isInitialized = false;
                      detailPublicationXmlViewModel.searchController.clear();
                      goRouter.pop();
                    },
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),
                actions: [
                  NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () {
                      detailPublicationXmlViewModel.searchController.clear();
                      goRouter.go(Paths.notifications);
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
    final detailPublicationXmlViewModel = ref.watch(detailPublicationXmlProvider);
    final orderedFields = detailPublicationXmlViewModel.orderedFieldsListItem;

    final searchText = detailPublicationXmlViewModel.searchController.text;
    final isEmpty = detailPublicationXmlViewModel.isEmpty;

    return orderedFields.isEmpty
        ? const SizedBox()
        : isEmpty && searchText.isNotEmpty
            ? AtomNoResult(
                isDarkMode: isDarkMode,
                query: searchText,
                text: 'Publication',
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
                          ..._buildPublicationContent(context, ref, isDarkMode, searchText),
                        ],
                      ),
                    ),
                    _buildRecommendedSection(context, ref, isDarkMode),
                  ],
                ),
              );
  }

  List<Widget> _buildPublicationContent(BuildContext context, WidgetRef ref, bool isDarkMode, String searchText) {
    final detailPublicationXmlViewModel = ref.watch(detailPublicationXmlProvider);
    final orderedFields = detailPublicationXmlViewModel.orderedFieldsListItem;

    final List<Widget> widgets = [];

    final List<String> dateParts = [];
    bool dateWidgetAdded = false;

    final dateFields = orderedFields.map((e) => (e.balise ?? '').toLowerCase()).where((b) => b == 'pubdate' || b == 'updatedate').toList();
    final String? lastDateField = dateFields.isNotEmpty ? dateFields.last : null;

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (publication.title.isNotEmpty) {
            widgets.addAll([
              15.ph,
              AtomHighlightedText(
                text: publication.title,
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
          if (publication.summary.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: publication.summary,
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
          if (publication.mainImage.isNotEmpty) {
            widgets.addAll([
              25.ph,
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: publication.mainImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ]);
          }
          break;

        case 'imagecaption':
          if (publication.imageCaption.isNotEmpty) {
            widgets.addAll([
              10.ph,
              AtomHighlightedText(
                text: publication.imageCaption,
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
          if (publication.content.isNotEmpty) {
            widgets.addAll([
              25.ph,
              AtomHighlightedText(
                text: publication.content,
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
          if (publication.category.isNotEmpty) {
            widgets.addAll([
              20.ph,
              AtomHighlightedText(
                text: publication.category,
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
        case 'download':
          break;
        case 'download - icon':
          break;
        case 'download - title':
          break;
        case 'download - type':
          break;
        case 'download - size':
          break;
        case 'download - link':
          if (_shouldShowDownloadWidget(publication.downloadFile)) {
            widgets.addAll([
              25.ph,
              _buildDownloadWidget(context, publication.downloadFile, searchText, isDarkMode),
              25.ph,
            ]);
          }
          break;

        ///date de publication
        case 'pubdate':
          if (publication.pubDate.isNotEmpty) {
            dateParts.add('Publié le ${_formatDate(publication.pubDate)}');
          }
          break;

        ///date de mise à jour
        case 'updatedate':
          if (publication.updateDate.isNotEmpty) {
            dateParts.add('Mis à jour le ${_formatDate(publication.updateDate)}');
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

  bool _shouldShowDownloadWidget(DownloadFile downloadFile) => downloadFile.link.isNotEmpty || downloadFile.title.isNotEmpty || downloadFile.type.isNotEmpty || downloadFile.size.isNotEmpty;

  Widget _buildDownloadWidget(BuildContext context, DownloadFile downloadFile, String searchQuery, bool isDarkMode) => Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: isDarkMode ? onPrimaryDark : onPrimaryLight,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 23.2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (downloadFile.title.isNotEmpty) ...[
                    AtomHighlightedText(
                      text: downloadFile.title,
                      searchQuery: searchQuery,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                          ),
                      isDarkMode: isDarkMode,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.ph,
                  ],
                  Row(
                    children: [
                      if (downloadFile.type.isNotEmpty) ...[
                        AtomHighlightedText(
                          text: downloadFile.type.toUpperCase(),
                          searchQuery: searchQuery,
                          style: Theme.of(context).textTheme.labelSmall!,
                          isDarkMode: isDarkMode,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                      if (downloadFile.type.isNotEmpty && downloadFile.size.isNotEmpty) ...[
                        AtomHighlightedText(
                          text: ' - ',
                          searchQuery: searchQuery,
                          style: Theme.of(context).textTheme.labelSmall!,
                          isDarkMode: isDarkMode,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                      if (downloadFile.size.isNotEmpty) ...[
                        AtomHighlightedText(
                          text: downloadFile.size,
                          searchQuery: searchQuery,
                          style: Theme.of(context).textTheme.labelSmall!,
                          isDarkMode: isDarkMode,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (downloadFile.link.isNotEmpty) ...[
              16.pw,
              GestureDetector(
                onTap: () => _downloadFile(context, downloadFile.link),
                child: Icon(
                  Icons.save_alt,
                  color: isDarkMode ? primaryDark : primaryLight,
                ),
              ),
            ],
          ],
        ),
      );

  Future<void> _downloadFile(BuildContext context, String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossible d'ouvrir le lien de téléchargement"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRecommendedSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final detailPublicationXmlViewModel = ref.watch(detailPublicationXmlProvider);
    final recommendedPublications = detailPublicationXmlViewModel.getRecommendedPublications(publication, ref);

    if (recommendedPublications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.ph,
          AtomText(
            data: 'À lire aussi...',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
            ),          ),
          15.ph,
          SizedBox(
            height: 350,
            child: ListView.separated(
              itemCount: recommendedPublications.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final publication = recommendedPublications[index];
                final isLast = index == recommendedPublications.length - 1;
                if (isLast) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildRecommendedCard(context, ref, publication, isDarkMode),
                  );
                }
                return _buildRecommendedCard(context, ref, publication, isDarkMode);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
          80.ph,
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, WidgetRef ref, Publication publication, bool isDarkMode) => InkWell(
        onTap: () {
          final detailPublicationXmlViewModel = ref.read(detailPublicationXmlProvider);
          detailPublicationXmlViewModel.isInitialized = false;
          detailPublicationXmlViewModel.searchController.clear();
          goRouter.go(
            Paths.detailPublicationXml,
            extra: {
              'tileXml': tileXml,
              'publicationXml': publication,
              'allPublications': allPublications,
            },
          );
        },
        child: SizedBox(
          width: Helpers.getResponsiveWidth(context) * .45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRecommendedCardContent(context, ref, publication, isDarkMode),
          ),
        ),
      );

  List<Widget> _buildRecommendedCardContent(BuildContext context, WidgetRef ref, Publication publication, bool isDarkMode) {
    final detailViewModel = ref.read(detailPublicationXmlProvider);
    final fieldsConfig = ref.watch(detailViewModel.fieldsConfiguration);
    final fieldsToUse = fieldsConfig.isNotEmpty ? fieldsConfig : ref.read(publicationsXmlProvider).orderedFieldsSingleList;

    final widgets = <Widget>[];
    for (final field in fieldsToUse) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (publication.title.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 80,
                child: AtomHighlightedText(
                  text: publication.title,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
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
          if (publication.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: publication.mainImage,
                    fit: BoxFit.cover,
                    width: Helpers.getResponsiveWidth(context) * .3,
                    height: 185,
                  ),
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'category':
          if (publication.category.isNotEmpty) {
            widgets.addAll([
              SizedBox(
                height: 30,
                child: AtomHighlightedText(
                  text: publication.category,
                  searchQuery: '',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: isDarkMode ? primaryDark : primaryLight,
                      ),
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
    final detailPublicationXmlViewModel = ref.watch(detailPublicationXmlProvider);
    final isFavorite = ref.watch(detailPublicationXmlViewModel.isFavorite);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'publicationXmlViewWrapper${detailPublicationXmlViewModel.favoriteButtonTag}',
          onPressed: () => detailPublicationXmlViewModel.onPressFavorite(ref, tileXml, publication),
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
      ],
    );
  }
}
