import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../core/extensions/tile_extension.dart';
import '../../../../../../core/utils/icon_picto_helper.dart';
import '../../../../../../design_system/atoms/atom_floating_action_button_favorite.dart';
import '../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../design_system/atoms/atom_text.dart';
import '../../../../../../design_system/molecules/molecule_stone.dart';
import '../../../../../../router/navigation_service.dart';
import '../../../../../../router/routes.dart';
import '../../../../../favorites/domain/repositories/favorite_domain_module.dart';
import '../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../domain/modals/tile_quick_access.dart';
import '../../../viewmodel/quick_access/quick_access_tile_view_model.dart';

class QuickAccessTileViewWrapper extends ConsumerStatefulWidget {
  final bool withScaffold;
  final TileQuickAccess tileQuickAccess;

  const QuickAccessTileViewWrapper({
    required this.tileQuickAccess,
    required this.withScaffold,
    super.key,
  });

  @override
  ConsumerState<QuickAccessTileViewWrapper> createState() => _QuickAccessTileViewWrapperState();
}

class _QuickAccessTileViewWrapperState extends ConsumerState<QuickAccessTileViewWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuickAccess();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeQuickAccess() async {
    if (_isInitialized) return;

    try {
      final quickAccessViewModel = ref.read(quickAccessTileProvider);
      await quickAccessViewModel.initQuickAccessTile(ref, widget.tileQuickAccess);
      ref.read(quickAccessViewModel.isFavorite.notifier).state = isFavorite();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation du contenu: $e");
    }
  }

  bool isFavorite() {
    final useCase = ref.watch(favoriteUseCaseProvider);
    final favoriteId = 'tile_quick_access_${widget.tileQuickAccess.id}';

    final isFavorite = useCase.isFavorite(favoriteId);
    return isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final quickAccessViewModel = ref.watch(quickAccessTileProvider);

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFCA542B)),
              16.ph,
              Text(
                "Initialisation de l'accès rapide...",
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
            fieldHintText: "Rechercher dans l'accès rapide...",
            customTextEditingController: ref.watch(homeProvider).searchController,
            clearSearchIcon: Icons.clear,
            onChanged: (text) => quickAccessViewModel.onSearchTextChanged(ref, text),
            onCleared: () => quickAccessViewModel.clearSearch(ref),
            animation: AppBarAnimationSlideLeft.call,
            appBarBuilder: (context) => AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              scrolledUnderElevation: 0,
              title: Text(
                'Accès rapide',
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
          body: _buildQuickAccessTile(quickAccessViewModel, isDarkMode),
          floatingActionButton: _buildFloatingActionButton(
            onPressed: () => quickAccessViewModel.onPressFavorite(ref, widget.tileQuickAccess),
            isDarkMode: isDarkMode,
            isFavorite: ref.watch(quickAccessViewModel.isFavorite),
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          _buildQuickAccessTile(quickAccessViewModel, isDarkMode),
          _buildFloatingActionButton(
            onPressed: () => quickAccessViewModel.onPressFavorite(ref, widget.tileQuickAccess),
            isDarkMode: isDarkMode,
            isFavorite: ref.watch(quickAccessViewModel.isFavorite),
            isPositioned: true,
          ),
        ],
      );
    }
  }

  Widget _buildQuickAccessTile(QuickAccessTileProvider quickAccessViewModel, bool isDarkMode) {
    final String searchQuery = ref.watch(ref.watch(homeProvider).searchText);
    final TileQuickAccess? filteredQuickAccess = ref.watch(quickAccessViewModel.quickAccessFiltered);
    final int resultsCount = quickAccessViewModel.getResultsCount(ref);
    final hasSearchResults = ref.watch(quickAccessViewModel.hasSearchResults);

    final quickAccessDetails = widget.tileQuickAccess;
    if (quickAccessDetails.results?.data == null) return const SizedBox();

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
                  data: '$resultsCount résultat(s) trouvé(s) pour "$searchQuery"',
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
                  text: 'Accès rapide',
                )
              : filteredQuickAccess != null
                  ? WallLayout(
                      stones: filteredQuickAccess.results!.data!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final sizeQuickAccess = data.sizeQuickAccess ?? '1*1';
                        final separatorChar = sizeQuickAccess.contains('*') ? '*' : 'x';
                        final sizeParts = sizeQuickAccess.split(separatorChar);
                        final width = int.tryParse(sizeParts[0]) ?? 1;
                        final height = int.tryParse(sizeParts.length > 1 ? sizeParts[1] : '1') ?? 1;

                        final background = Helpers.hexToColor((data.colorBackground ?? '').isNotEmpty ? data.colorBackground! : '#00000000');
                        final borderColorParsed = Helpers.hexToColor((data.borderColor ?? '').isNotEmpty ? data.borderColor! : '#00000000');
                        final colorText = Helpers.hexToColor((data.titleColor ?? '').isNotEmpty ? data.titleColor! : '#00000000');

                        final borderRadius = double.tryParse(data.radiusBorder ?? '0') ?? 0.0;
                        final borderWidth = double.tryParse(data.edgeBorder ?? '0') ?? 0.0;

                        final pictogram = data.pictogram?.url ?? '';
                        final localImagePath = data.pictogram?.localPath ?? '';
                        final String pictogramName = (data.pictogram?.url ?? '').split('/').last;
                        final text = data.title ?? '';

                        IconData? pictogramIcon;
                        if (pictogram.isEmpty && (data.automaticPictogram ?? '').isNotEmpty) {
                          final int indexIcon = int.parse(data.automaticPictogram ?? '0');
                          pictogramIcon = listPicto[indexIcon].icon;
                        }



                        return Stone(
                          id: index,
                          width: width,
                          height: height,
                          child: MoleculeStone(
                            background: background,
                            text: text,
                            borderRadius: borderRadius,
                            borderColor: borderColorParsed,
                            borderWidth: borderWidth,
                            base64ImageData: pictogram,
                            colorText: colorText,
                            height: height,
                            iconData: pictogramIcon,
                            localImagePath: localImagePath,
                            labelImage: pictogramName,
                            onTap: () async {
                              if ((data.typeLink ?? '') == '1') {
                                await context.redirectToTile(ref, data.tile ?? '', true);
                              } else if ((data.typeLink ?? '') == '2') {
                                NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: data.urlLink ?? '');
                              }
                            },
                            isDarkMode: isDarkMode,
                            searchQuery: searchQuery,
                          ),
                        );
                      }).toList(),
                      layersCount: 3,
                    )
                  : const Center(
                      child: Text('Aucun contenu à afficher'),
                    ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton({required VoidCallback onPressed, required bool isDarkMode, required bool isFavorite, bool isPositioned = false}) {
    final buttonColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AtomFloatingActionButtonFavorite(
          heroTag: 'quickAccessViewWrapper${widget.tileQuickAccess.id}',
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
