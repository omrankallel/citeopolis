import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/core.dart';
import '../../../../../core/extensions/tile_extension.dart';
import '../../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../../design_system/molecules/molecule_content.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../../content_detail/presentation/viewmodel/content_detail_view_model.dart';
import '../../../../home/domain/modals/content_home/publication.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../viewmodel/content_home_view_model.dart';

class OrganismPublications extends ConsumerWidget {
  final bool isLast;
  final Publication? publication;
  final int selectedIndex;

  const OrganismPublications({required this.selectedIndex, required this.publication, required this.isLast, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentHomeViewModel = ref.watch(contentHomeProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final String searchText = ref.read(ref.watch(homeProvider).searchText.notifier).state;
    return Column(
      children: [
        20.ph,
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AtomTextIcon(
                data: publication?.titlePublication ?? 'Publications',
                onTap: () async {
                  if ((publication?.typeLinkPublication ?? '') == '1') {
                    await context.redirectToTile(ref, publication?.tile ?? '', true);
                  } else if ((publication?.typeLinkPublication ?? '') == '2') {
                    NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: publication?.urlLink ?? '');
                  }
                },
                isDarkMode: isDarkMode,
                searchQuery: searchText,
              ),
              20.ph,
              if (publication?.displayMode == '1' && publication?.publicationRepeater != null && publication!.publicationRepeater!.isNotEmpty) ...[
                SizedBox(
                  height: 310,
                  child: ListView.separated(
                    itemCount: publication?.publicationRepeater?.length ?? 0,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    cacheExtent: 600,
                    itemBuilder: (buildContext, index) {
                      final repeater = publication?.publicationRepeater?[index];
                      if (repeater == null) return const SizedBox.shrink();
                      final bool isLast = index == publication!.publicationRepeater!.length - 1;

                      return Container(
                        width: Helpers.getResponsiveWidth(context) * .45,
                        padding: EdgeInsets.only(right: isLast ? 16.0 : 0),
                        child: MoleculeContent(
                          key: ValueKey('pub_${repeater.repPictoImg ?? index}'),
                          base64ImageData: repeater.repPictoImg,
                          localImagePath: repeater.localPath,
                          labelImage: repeater.repPictoImg ?? ''.split('/').last,
                          thematic: repeater.repThematic ?? '',
                          chapeau: repeater.repTitle ?? '',
                          sizeImage: Size(Helpers.getResponsiveWidth(context) * .3, 185),
                          styleThematic: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: isDarkMode ? primaryDark : primaryLight,
                              ),
                          styleChapeau: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                              ),
                          onTap: () async {
                            final repeater = publication?.publicationRepeater?[index];
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
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 16,
                    ),
                  ),
                ),
              ] else if ((publication?.displayMode ?? '') == '2') ...[
                buildWidgetFluxXmlRSS(ref, contentHomeViewModel, publication, isDarkMode, searchText),
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

  Widget buildWidgetFluxXmlRSS(WidgetRef ref, ContentHomeProvider contentHomeViewModel, Publication? publication, bool isDarkMode, String searchQuery) {
    final fluxXmlRSS = publication?.fluxXmlRSSChannel;
    final numberElement = int.parse(publication?.flux?.numberElement ?? '0');
    final numberOfItems = numberElement > 4 ? 4 : numberElement;
    if (fluxXmlRSS == null || fluxXmlRSS.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final limitedItems = fluxXmlRSS.items.take(numberOfItems).toList();
    final hasMoreItems = fluxXmlRSS.items.length > numberOfItems;
    return SizedBox(
      height: 310,
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
                width: Helpers.getResponsiveWidth(context) * .45,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 28,
                        color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Afficher plus',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                            ),
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
            width: Helpers.getResponsiveWidth(context) * .45,
            padding: EdgeInsets.only(right: isLast ? 16.0 : 0),
            child: MoleculeContent(
              key: ValueKey('publication_rss_${item.title ?? index}'),
              localImagePath: item.localPath,
              thematic: item.category ?? '',
              chapeau: item.title ?? '',
              sizeImage: Size(Helpers.getResponsiveWidth(context) * .3, 185),
              styleThematic: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: isDarkMode ? primaryDark : primaryLight,
                  ),
              styleChapeau: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                  ),
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
