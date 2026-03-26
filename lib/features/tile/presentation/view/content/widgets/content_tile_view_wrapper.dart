import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:badges/badges.dart' as bg;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../../core/core.dart';
import '../../../../../../../design_system/atoms/atom_floating_action_button_favorite.dart';
import '../../../../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../design_system/atoms/atom_text.dart';
import '../../../../../../../router/routes.dart';
import '../../../../../../router/navigation_service.dart';
import '../../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../domain/modals/tile_content.dart';
import '../../../viewmodel/content/content_tile_view_model.dart';

class ContentTileViewWrapper extends ConsumerStatefulWidget {
  final bool withScaffold;
  final TileContent tileContent;

  const ContentTileViewWrapper({
    required this.tileContent,
    required this.withScaffold,
    super.key,
  });

  @override
  ConsumerState<ContentTileViewWrapper> createState() => _ContentViewWrapperState();
}

class _ContentViewWrapperState extends ConsumerState<ContentTileViewWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeContent();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeContent() async {
    if (_isInitialized) return;

    try {
      final contentTileViewModel = ref.read(contentTileProvider);
      await contentTileViewModel.initContentTile(ref, widget.tileContent);
      ref.read(contentTileViewModel.isFavorite.notifier).state = isFavorite();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation du contenu: $e");
    }
  }

  bool isFavorite() {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = 'tile_content_${widget.tileContent.id}';

    final isFavorite = useCase.isFavorite(favoriteId);
    return isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final contentTileViewModel = ref.watch(contentTileProvider);

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFCA542B)),
              16.ph,
              Text(
                'Initialisation du contenu...',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.withScaffold) {
      return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          drawerEnableOpenDragGesture: false,
          appBar: AppBarWithSearchSwitch(
            fieldHintText: 'Rechercher dans le contenu...',
            customTextEditingController: ref.watch(homeProvider).searchController,
            clearSearchIcon: Icons.clear,
            onChanged: (text) => contentTileViewModel.onSearchTextChanged(ref, text),
            onCleared: () => contentTileViewModel.clearSearch(ref),
            animation: AppBarAnimationSlideLeft.call,
            appBarBuilder: (context) => AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              scrolledUnderElevation: 0,
              title: Text(
                'Contenu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
          body: _buildContentView(contentTileViewModel, isDarkMode),
          floatingActionButton: _buildFloatingActionButton(
            onPressed: () => contentTileViewModel.onPressFavorite(ref, widget.tileContent),
            isDarkMode: isDarkMode,
            isFavorite: ref.watch(contentTileViewModel.isFavorite),
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          _buildContentView(contentTileViewModel, isDarkMode),
          _buildFloatingActionButton(
            onPressed: () => contentTileViewModel.onPressFavorite(ref, widget.tileContent),
            isDarkMode: isDarkMode,
            isFavorite: ref.watch(contentTileViewModel.isFavorite),
            isPositioned: true,
          ),
        ],
      );
    }
  }

  Widget _buildContentView(ContentTileProvider contentTileViewModel, bool isDarkMode) {
    final searchQuery = ref.watch(ref.watch(homeProvider).searchText);
    final filteredContent = ref.watch(contentTileViewModel.contentFiltered);
    final hasSearchResults = ref.watch(contentTileViewModel.hasSearchResults);

    return Column(
      children: [
        if (searchQuery.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                8.pw,
                AtomText(
                  data: '${contentTileViewModel.getResultsCount(ref)} résultat(s) trouvé(s) pour "$searchQuery"',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: searchQuery.isNotEmpty && !hasSearchResults
              ? AtomNoResult(
            isDarkMode: isDarkMode,
            query: searchQuery,
            text: 'Contenu',
          )
              : filteredContent != null
              ? _buildContentDisplay(filteredContent, searchQuery, isDarkMode)
              : const Center(
            child: Text('Aucun contenu à afficher'),
          ),
        ),
      ],
    );
  }

  Widget _buildContentDisplay(TileContent content, String searchQuery, bool isDarkMode) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          50.ph,
          if (content.results!.descTile != null && content.results!.descTile!.isNotEmpty) ...[
            AtomHighlightedText(
              text: widget.tileContent.results?.descTile ?? '',
              searchQuery: searchQuery,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
              ),
              isDarkMode: isDarkMode,
              overflow: TextOverflow.visible,
            ),
            30.ph,
          ],
          if (content.results!.imgTile != null && content.results!.imgTile!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: content.results!.imgTile!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            20.ph,
          ],
          if (content.results!.contentTile != null && content.results!.contentTile!.isNotEmpty) ...[
            AtomHighlightedText(
              text: content.results!.contentTile!,
              searchQuery: searchQuery,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
              ),
              isHtml: true,
              isDarkMode: isDarkMode,
              overflow: TextOverflow.visible,
            ),
          ],
          50.ph,
        ],
      ),
    ),
  );

  Widget _buildFloatingActionButton({required VoidCallback onPressed, required bool isDarkMode, required bool isFavorite, bool isPositioned = false}) {
    final buttonColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'tileContentViewWrapper${widget.tileContent.id}',
          onPressed: onPressed,
          assetPath: Assets.assetsImageSaveDark,
          isDarkMode: isDarkMode,
          isFavorite: isFavorite,
        ),
        10.ph,
        if (!isPositioned) 50.ph,
      ],
    );
    if (isPositioned) {
      return Positioned(
        right: 10,
        bottom: 50,
        child: buttonColumn,
      );
    }

    return buttonColumn;
  }
}
