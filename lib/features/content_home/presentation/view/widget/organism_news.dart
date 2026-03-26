import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/core.dart';
import '../../../../../core/extensions/tile_extension.dart';
import '../../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../../design_system/molecules/molecule_content.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../../content_detail/presentation/viewmodel/content_detail_view_model.dart';
import '../../../../home/domain/modals/content_home/news.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../viewmodel/content_home_view_model.dart';

class OrganismNews extends ConsumerWidget {
  final bool isLast;
  final News? news;
  final int selectedIndex;

  const OrganismNews({required this.selectedIndex, required this.news, required this.isLast, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentHomeViewModel = ref.watch(contentHomeProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final String searchText = ref.read(ref.watch(homeProvider).searchText.notifier).state;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.ph,
              AtomTextIcon(
                data: news?.titleNews ?? 'Actualités',
                onTap: () async {
                  if ((news?.typeLinkNews ?? '') == '1') {
                    await context.redirectToTile(ref, news?.tile ?? '', true);
                  } else if ((news?.typeLinkNews ?? '') == '2') {
                    NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: news?.urlLink ?? '');
                  }
                },
                isDarkMode: isDarkMode,
                searchQuery: searchText,
              ),
              20.ph,
              if (news?.displayMode == '1' && news?.newsRepeater != null && news!.newsRepeater!.isNotEmpty) ...[
                SizedBox(
                  height: 325,
                  child: ListView.separated(
                    itemCount: news?.newsRepeater?.length ?? 0,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    cacheExtent: 600,
                    itemBuilder: (buildContext, index) {
                      final repeater = news?.newsRepeater?[index];
                      if (repeater == null) return const SizedBox.shrink();
                      final bool isLast = index == news!.newsRepeater!.length - 1;

                      return Container(
                        width: Helpers.getResponsiveWidth(context) * .65,
                        padding: EdgeInsets.only(right: isLast ? 16.0 : 0),
                        child: MoleculeContent(
                          key: ValueKey('news_${repeater.repPictoImg ?? index}'),
                          base64ImageData: repeater.repPictoImg,
                          localImagePath: repeater.localPath,
                          labelImage: repeater.repPictoImg ?? ''.split('/').last,
                          thematic: repeater.repThematic ?? '',
                          chapeau: repeater.repTitle ?? '',
                          onTap: () async {
                            final repeater = news?.newsRepeater?[index];
                            if ((repeater?.repTypeLink ?? '') == '1') {
                              await context.redirectToTile(ref, repeater?.repTile ?? '', true);
                            } else if ((repeater?.repTypeLink ?? '') == '2') {
                              NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: repeater?.repUrl ?? '');
                            }
                          },
                          isDarkMode: isDarkMode,
                          searchQuery: searchText,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                  ),
                ),
              ] else if ((news?.displayMode ?? '') == '2') ...[
                buildWidgetFluxXmlRSS(ref, contentHomeViewModel, news, isDarkMode, searchText),
              ],
            ],
          ),
        ),
        if (isLast) ...[
          40.ph,
        ] else ...[
          40.ph,
          const Divider(color: Color(0XFFCAC4D0), indent: 0, endIndent: 0, thickness: 1),
          40.ph,
        ],
      ],
    );
  }

  Widget buildWidgetFluxXmlRSS(WidgetRef ref, ContentHomeProvider contentHomeViewModel, News? news, bool isDarkMode, String searchQuery) {
    final fluxXmlRSS = news?.fluxXmlRSSChannel;
    final numberElement = int.parse(news?.flux?.numberElement ?? '0');
    final numberOfItems = numberElement > 4 ? 4 : numberElement;
    if (fluxXmlRSS == null || fluxXmlRSS.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final limitedItems = fluxXmlRSS.items.take(numberOfItems).toList();
    final hasMoreItems = fluxXmlRSS.items.length > numberOfItems;

    return SizedBox(
      height: 325,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        cacheExtent: 600,
        itemCount: limitedItems.length + (hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasMoreItems && index == limitedItems.length) {
            return GestureDetector(
              onTap: () async {
                await ref.watch(contentDetailProvider).initialise(ref, selectedIndex);
                if (context.mounted) {
                  NavigationService.go(context, ref, Paths.contentDetail);
                }
              },
              child: Container(
                width: Helpers.getResponsiveWidth(context) * .65,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, size: 28, color: isDarkMode ? onSurfaceDark : onSurfaceLight),
                      const SizedBox(height: 8),
                      Text(
                        'Afficher plus',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: isDarkMode ? onSurfaceDark : onSurfaceLight),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final item = limitedItems[index];
          final bool isLast = index == limitedItems.length - 1 && !hasMoreItems;
          return Container(
            width: Helpers.getResponsiveWidth(context) * .65,
            padding: EdgeInsets.only(right: isLast ? 16.0 : 0),
            child: MoleculeContent(
              key: ValueKey('news_rss_${item.title ?? index}'),
              localImagePath: item.localPath,
              thematic: item.category ?? '',
              chapeau: item.title ?? '',
              onTap: () async {
                NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: item.link ?? '');
              },
              isDarkMode: isDarkMode,
              searchQuery: searchQuery,
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }
}
