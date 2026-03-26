import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/core.dart';
import '../../../../../core/extensions/tile_extension.dart';
import '../../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../../design_system/molecules/molecule_content.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../../content_detail/presentation/viewmodel/content_detail_view_model.dart';
import '../../../../home/domain/modals/content_home/event.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../viewmodel/content_home_view_model.dart';

class OrganismEvents extends ConsumerWidget {
  final bool isLast;
  final Event? event;
  final int selectedIndex;

  const OrganismEvents({required this.selectedIndex, required this.event, required this.isLast, super.key});

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
                data: event?.titleEvent ?? 'Événements',
                onTap: () async {
                  if ((event?.typeLinkEvent ?? '') == '1') {
                    await context.redirectToTile(ref, event?.tile ?? '', true);
                  } else if ((event?.typeLinkEvent ?? '') == '2') {
                    NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: event?.urlLink ?? '');
                  }
                },
                isDarkMode: isDarkMode,
                searchQuery: searchText,
              ),
              20.ph,
              if (event?.displayMode == '1' && event?.eventRepeater != null && event!.eventRepeater!.isNotEmpty) ...[
                SizedBox(
                  height: 415,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    cacheExtent: 600,
                    padding: EdgeInsets.zero,
                    itemCount: event!.eventRepeater?.length ?? 0,
                    itemBuilder: (context, index) {
                      final repeater = event?.eventRepeater![index];
                      if (repeater == null) return const SizedBox.shrink();

                      String date = '';
                      if ((repeater.repStartDate ?? '').isNotEmpty && (repeater.repEndDate ?? '').isNotEmpty) {
                        date = 'Du ${Helpers.convertDate(repeater.repStartDate ?? '')} au ${Helpers.convertDate(repeater.repEndDate ?? '')}';
                      } else if ((repeater.repStartDate ?? '').isNotEmpty) {
                        date = 'Le ${Helpers.convertDate(repeater.repStartDate ?? '')}';
                      } else if ((repeater.repEndDate ?? '').isNotEmpty) {
                        date = "Jusqu'au ${Helpers.convertDate(repeater.repEndDate ?? '')}";
                      }
                      final bool isLast = index == event!.eventRepeater!.length - 1;

                      return Container(
                        width: Helpers.getResponsiveWidth(context) * .65,
                        padding: EdgeInsets.only(right: isLast ? 16.0 : 0),
                        child: MoleculeContent(
                          key: ValueKey('event_${repeater.repPictoImg ?? index}'),
                          base64ImageData: repeater.repPictoImg,
                          localImagePath: repeater.localPath,
                          labelImage: repeater.repPictoImg ?? ''.split('/').last,
                          thematic: repeater.repThematic ?? '',
                          chapeau: repeater.repTitle ?? '',
                          date: date,
                          styleDate: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: isDarkMode ? primaryDark : primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                          onTap: () async {
                            final repeater = event?.eventRepeater?[index];
                            if ((repeater?.repTypeLink ?? '') == '1') {
                              await context.redirectToTile(ref, repeater?.repTile ?? '', true);
                            } else if ((repeater?.repTypeLink ?? '') == '2') {
                              NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: repeater?.repUrl ?? '');
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
              ] else if ((event?.displayMode ?? '') == '2') ...[
                buildWidgetFluxXmlRSS(ref, contentHomeViewModel, event, isDarkMode, searchText),
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

  Widget buildWidgetFluxXmlRSS(WidgetRef ref, ContentHomeProvider contentHomeViewModel, Event? event, bool isDarkMode, String searchQuery) {
    final fluxXmlRSS = event?.fluxXmlRSSChannel;
    final numberElement = int.parse(event?.flux?.numberElement ?? '0');
    final numberOfItems = numberElement > 4 ? 4 : numberElement;
    if (fluxXmlRSS == null || fluxXmlRSS.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final limitedItems = fluxXmlRSS.items.take(numberOfItems).toList();
    final hasMoreItems = fluxXmlRSS.items.length > numberOfItems;

    return SizedBox(
      height: 415,
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
                  NavigationService.go(context,ref,Paths.contentDetail);
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

          String date = '';
          if ((item.eventStartDate ?? '').isNotEmpty && (item.eventEndDate ?? '').isNotEmpty) {
            date = 'Du ${Helpers.convertDate(item.eventStartDate ?? '')} au ${Helpers.convertDate(item.eventEndDate ?? '')}';
          } else if ((item.eventStartDate ?? '').isNotEmpty) {
            date = 'Le ${Helpers.convertDate(item.eventStartDate ?? '')}';
          } else if ((item.eventEndDate ?? '').isNotEmpty) {
            date = "Jusqu'au ${Helpers.convertDate(item.eventEndDate ?? '')}";
          }
          final bool isLast = index == limitedItems.length - 1 && !hasMoreItems;

          return Container(
            width: Helpers.getResponsiveWidth(context) * .65,
            padding: EdgeInsets.only(right: isLast ? 16.0 : 0),
            child: MoleculeContent(
              key: ValueKey('event_rss_${item.title ?? index}'),
              localImagePath: item.localPath,
              thematic: item.category ?? '',
              chapeau: item.title ?? '',
              date: date,
              styleDate: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
              onTap: () async {
                NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: item.link ?? '');
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
