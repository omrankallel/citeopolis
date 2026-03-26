import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/tile_extension.dart';
import '../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../design_system/atoms/atom_error_connexion.dart';
import '../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../design_system/atoms/atom_no_result.dart';
import '../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../design_system/organism/organism_content_card.dart';
import '../../../../router/navigation_service.dart';
import '../../../../router/routes.dart';
import '../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../home/presentation/viewmodel/content_home/content_home_list_view_model.dart';
import '../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../viewmodel/content_detail_view_model.dart';

class ContentDetailView extends ConsumerStatefulWidget {
  const ContentDetailView({super.key});

  @override
  ConsumerState<ContentDetailView> createState() => _ContentDetailViewState();
}

class _ContentDetailViewState extends ConsumerState<ContentDetailView> {
  @override
  Widget build(BuildContext context) {
    final contentDetailViewModel = ref.watch(contentDetailProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final String searchQuery = ref.read(contentDetailViewModel.searchText.notifier).state;
    final hasSearchResults = ref.watch(contentDetailViewModel.hasSearchResults);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: contentDetailViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawerEnableOpenDragGesture: false,
        endDrawer: AtomEndDrawer(
          scaffoldKey: contentDetailViewModel.scaffoldKey,
          textFilter: 'Filtrer les ${contentDetailViewModel.textTitle(ref)}',
          isDarkMode: ref.watch(themeProvider).isDarkMode,
          thematicListFilter: ref.watch(contentDetailViewModel.thematics),
          selectedList: ref.watch(contentDetailViewModel.selectedList),
          onSelected: (value, index) {
            ref.read(contentDetailViewModel.selectedList.notifier).update(
                  (state) => [
                    for (int j = 0; j < state.length; j++)
                      if (j == index) value else state[j],
                  ],
                );
          },
          startDate: contentDetailViewModel.startDate,
          endDate: contentDetailViewModel.endDate,
          onApplyFilters: () {
            contentDetailViewModel.applyFilters(ref);
          },
          onClearFilters: () {
            contentDetailViewModel.clearFilters(ref);
          },
          showFilteredDate: (ref.watch(contentDetailViewModel.filteredSection).type ?? '') == 'event',
        ),
        appBar: AppBarWithSearchSwitch(
          fieldHintText: 'Rechercher...',
          customTextEditingController: contentDetailViewModel.searchController,
          clearSearchIcon: Icons.clear,
          onChanged: (text) => contentDetailViewModel.onSearchTextChanged(ref, text),
          onCleared: () => contentDetailViewModel.clearSearch(ref),
          animation: AppBarAnimationSlideLeft.call,
          appBarBuilder: (context) => AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            scrolledUnderElevation: 0,
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
            actions: [
              const AppBarSearchButton(),
              20.pw,
              NotificationIconBadge(
                iconData: Icons.notifications_none_sharp,
                onTap: () => NavigationService.push(context, ref, Paths.notifications),
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
        ),
        body: ref.watch(buildPageListProvider).maybeMap(
              orElse: () => const Center(child: CircularProgressIndicator()),
              success: (buildPageData) {
                buildPageData.data.fold((l) => Container(), (data) async {
                  contentDetailViewModel.initialiseContentHome(ref, data);
                });

                final filteredContent = ref.watch(contentDetailViewModel.filteredSection);

                return RefreshIndicator(
                  onRefresh: () async {
                    contentDetailViewModel.clearSearch(ref);
                    await Future.wait([
                      ref.read(buildPageViewModelStateNotifierProvider.notifier).refreshFromServer(),
                    ]);
                  },
                  child: searchQuery.isNotEmpty && !hasSearchResults
                      ? CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: AtomNoResult(
                                  isDarkMode: isDarkMode,
                                  query: searchQuery,
                                  text: 'Détails',
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                20.ph,
                                Row(
                                  children: [
                                    AtomHighlightedText(
                                      text: contentDetailViewModel.textTitle(ref),
                                      searchQuery: searchQuery,
                                      style: Theme.of(context).textTheme.headlineLarge!,
                                      isDarkMode: isDarkMode,
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () => contentDetailViewModel.scaffoldKey.currentState?.openEndDrawer(),
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        width: 90,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFF757579),
                                          ),
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
                                26.ph,
                                if ((ref.watch(contentDetailViewModel.filteredSection).type ?? '') == 'news') ...[
                                  if ((filteredContent.news?.displayMode ?? '') == '1') ...[
                                    ListView.separated(
                                      itemCount: filteredContent.news?.newsRepeater?.length ?? 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (buildContext, index) {
                                        final repeater = filteredContent.news?.newsRepeater?[index];
                                        if (repeater == null) return const SizedBox.shrink();

                                        return OrganismContentCard(
                                          backgroundColor: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
                                          base64ImageData: repeater.repPictoImg,
                                          localImagePath: repeater.localPath,
                                          labelImage: repeater.repPictoImg ?? ''.split('/').last,
                                          thematic: repeater.repThematic ?? '',
                                          chapeau: repeater.repTitle ?? '',
                                          sizeImage: const Size(double.infinity, 160),
                                          onTap: () async {
                                            if ((repeater.repTypeLink ?? '') == '1') {
                                              await context.redirectToTile(ref, repeater.repTile ?? '', true);
                                            } else if ((repeater.repTypeLink ?? '') == '2') {
                                              NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: repeater.repUrl ?? '');
                                            }
                                          },
                                          isDarkMode: isDarkMode,
                                          searchQuery: searchQuery,
                                        );
                                      },
                                      separatorBuilder: (context, index) => 32.ph,
                                    ),
                                  ] else if ((filteredContent.news?.displayMode ?? '') == '2') ...[
                                    ListView.separated(
                                      itemCount: filteredContent.news?.fluxXmlRSSChannel?.items.length ?? 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (buildContext, index) {
                                        final item = filteredContent.news?.fluxXmlRSSChannel?.items[index];
                                        if (item == null) return const SizedBox.shrink();

                                        return OrganismContentCard(
                                          backgroundColor: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
                                          localImagePath: item.localPath,
                                          thematic: item.category ?? '',
                                          chapeau: item.title ?? '',
                                          sizeImage: const Size(double.infinity, 160),
                                          onTap: () async {
                                            NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: item.link ?? '');
                                          },
                                          isDarkMode: isDarkMode,
                                          searchQuery: searchQuery,
                                        );
                                      },
                                      separatorBuilder: (context, index) => 32.ph,
                                    ),
                                  ],
                                ] else if ((ref.watch(contentDetailViewModel.filteredSection).type ?? '') == 'event') ...[
                                  if ((filteredContent.event?.displayMode ?? '') == '1') ...[
                                    ListView.separated(
                                      itemCount: filteredContent.event?.eventRepeater?.length ?? 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (buildContext, index) {
                                        final repeater = filteredContent.event?.eventRepeater?[index];
                                        if (repeater == null) return const SizedBox.shrink();

                                        String date = '';
                                        if ((repeater.repStartDate ?? '').isNotEmpty && (repeater.repEndDate ?? '').isNotEmpty) {
                                          date = 'Du ${Helpers.convertDate(repeater.repStartDate ?? '')} au ${Helpers.convertDate(repeater.repEndDate ?? '')}';
                                        } else if ((repeater.repStartDate ?? '').isNotEmpty) {
                                          date = 'Le ${Helpers.convertDate(repeater.repStartDate ?? '')}';
                                        } else if ((repeater.repEndDate ?? '').isNotEmpty) {
                                          date = "Jusqu'au ${Helpers.convertDate(repeater.repEndDate ?? '')}";
                                        }

                                        return OrganismContentCard(
                                          backgroundColor: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
                                          base64ImageData: repeater.repPictoImg,
                                          localImagePath: repeater.localPath,
                                          labelImage: repeater.repPictoImg ?? ''.split('/').last,
                                          thematic: repeater.repThematic ?? '',
                                          chapeau: repeater.repTitle ?? '',
                                          date: date,
                                          sizeImage: const Size(double.infinity, 160),
                                          onTap: () async {
                                            if ((repeater.repTypeLink ?? '') == '1') {
                                              await context.redirectToTile(ref, repeater.repTile ?? '', true);
                                            } else if ((repeater.repTypeLink ?? '') == '2') {
                                              NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: repeater.repUrl ?? '');
                                            }
                                          },
                                          isDarkMode: isDarkMode,
                                          searchQuery: searchQuery,
                                        );
                                      },
                                      separatorBuilder: (context, index) => 32.ph,
                                    ),
                                  ] else if ((filteredContent.event?.displayMode ?? '') == '2') ...[
                                    ListView.separated(
                                      itemCount: filteredContent.event?.fluxXmlRSSChannel?.items.length ?? 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (buildContext, index) {
                                        final item = filteredContent.event?.fluxXmlRSSChannel?.items[index];
                                        if (item == null) return const SizedBox.shrink();

                                        String date = '';
                                        if ((item.eventStartDate ?? '').isNotEmpty && (item.eventEndDate ?? '').isNotEmpty) {
                                          date = 'Du ${Helpers.convertDate(item.eventStartDate ?? '')} au ${Helpers.convertDate(item.eventEndDate ?? '')}';
                                        } else if ((item.eventStartDate ?? '').isNotEmpty) {
                                          date = 'Le ${Helpers.convertDate(item.eventStartDate ?? '')}';
                                        } else if ((item.eventEndDate ?? '').isNotEmpty) {
                                          date = "Jusqu'au ${Helpers.convertDate(item.eventEndDate ?? '')}";
                                        }

                                        return OrganismContentCard(
                                          backgroundColor: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
                                          localImagePath: item.localPath,
                                          thematic: item.category ?? '',
                                          chapeau: item.title ?? '',
                                          date: date,
                                          sizeImage: const Size(double.infinity, 160),
                                          onTap: () async {
                                            NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: item.link ?? '');
                                          },
                                          isDarkMode: isDarkMode,
                                          searchQuery: searchQuery,
                                        );
                                      },
                                      separatorBuilder: (context, index) => 32.ph,
                                    ),
                                  ],
                                ] else ...[
                                  if ((filteredContent.publication?.displayMode ?? '') == '1') ...[
                                    ListView.separated(
                                      itemCount: filteredContent.publication?.publicationRepeater?.length ?? 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (buildContext, index) {
                                        final repeater = filteredContent.publication?.publicationRepeater?[index];
                                        if (repeater == null) return const SizedBox.shrink();

                                        return OrganismContentCard(
                                          backgroundColor: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
                                          base64ImageData: repeater.repPictoImg,
                                          localImagePath: repeater.localPath,
                                          labelImage: repeater.repPictoImg ?? ''.split('/').last,
                                          thematic: repeater.repThematic ?? '',
                                          chapeau: repeater.repTitle ?? '',
                                          sizeImage: Size(Helpers.getResponsiveWidth(context) * .3, 150),
                                          axis: Axis.horizontal,
                                          onTap: () async {
                                            if ((repeater.repTypeLink ?? '') == '1') {
                                              await context.redirectToTile(ref, repeater.repTile ?? '', true);
                                            } else if ((repeater.repTypeLink ?? '') == '2') {
                                              NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: repeater.repUrl ?? '');
                                            }
                                          },
                                          isDarkMode: isDarkMode,
                                          searchQuery: searchQuery,
                                        );
                                      },
                                      separatorBuilder: (context, index) => 32.ph,
                                    ),
                                  ] else if ((filteredContent.publication?.displayMode ?? '') == '2') ...[
                                    ListView.separated(
                                      itemCount: filteredContent.publication?.fluxXmlRSSChannel?.items.length ?? 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (buildContext, index) {
                                        final item = filteredContent.publication?.fluxXmlRSSChannel?.items[index];
                                        if (item == null) return const SizedBox.shrink();

                                        return OrganismContentCard(
                                          backgroundColor: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
                                          localImagePath: item.localPath,
                                          thematic: item.category ?? '',
                                          chapeau: item.title ?? '',
                                          sizeImage: Size(Helpers.getResponsiveWidth(context) * .3, 150),
                                          axis: Axis.horizontal,
                                          onTap: () async {
                                            NavigationService.go(context, ref, Paths.urlTileWithScaffold, extra: item.link ?? '');
                                          },
                                          isDarkMode: isDarkMode,
                                          searchQuery: searchQuery,
                                        );
                                      },
                                      separatorBuilder: (context, index) => 32.ph,
                                    ),
                                  ],
                                ],
                                60.ph,
                              ],
                            ),
                          ),
                        ),
                );
              },
              error: (error) => AtomErrorConnexion(
                onTap: () {
                  ref.read(buildPageViewModelStateNotifierProvider.notifier).getPageHomeFromLocal();
                },
              ),
            ),
      ),
    );
  }
}
