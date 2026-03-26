import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/core.dart';
import '../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../design_system/atoms/atom_image.dart';
import '../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../design_system/atoms/atom_text.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../domain/modals/tile_map.dart';
import '../../viewmodel/map_view_model.dart';

class MapViewWrapper extends StatelessWidget {
  final bool withScaffold;
  final TileMap tileMap;

  const MapViewWrapper({
    required this.tileMap,
    required this.withScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final mapViewModel = ref.watch(mapProvider);
          mapViewModel.context = context;
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          mapViewModel.initializeMap(ref, tileMap, withScaffold);
          return withScaffold ? _buildWithScaffold(ref, isDarkMode, context) : _buildWithoutScaffold(ref, isDarkMode, context);
        },
      );

  Widget _buildWithScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final mapViewModel = ref.watch(mapProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: mapViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawerEnableOpenDragGesture: false,
        endDrawer: mapViewModel.atomEndDrawerMap(ref, mapViewModel.scaffoldKey, isDarkMode),
        appBar: AtomAppBarWithSearch(
          title: 'Carte',
          isDarkMode: isDarkMode,
          searchController: mapViewModel.searchController,
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
          onSearchChanged: (text) => mapViewModel.onSearchTextChanged(ref, text),
          onSearchCleared: () => mapViewModel.onSearchTextChanged(ref, ''),
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
        body: _buildContent(ref, isDarkMode),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buttonThematic(isDarkMode, () => mapViewModel.scaffoldKey.currentState?.openEndDrawer()),
            10.ph,
            buttonLocation(isDarkMode, () => mapViewModel.getUserLocation(ref)),
            50.ph,
          ],
        ),
      ),
    );
  }

  Widget _buildWithoutScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final mapViewModel = ref.watch(mapProvider);
    final homeViewModel = ref.watch(homeProvider);
    return Stack(
      children: [
        _buildContent(ref, isDarkMode),
        Positioned(
          right: 10,
          bottom: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buttonThematic(isDarkMode, () => homeViewModel.scaffoldKey.currentState?.openEndDrawer()),
              10.ph,
              buttonLocation(isDarkMode, () => mapViewModel.getUserLocation(ref)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buttonThematic(bool isDarkMode, Function()? onPressed) => FloatingActionButton.extended(
        heroTag: 'thematicFilter',
        onPressed: onPressed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        backgroundColor: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
        label: SvgPicture.asset(
          Assets.assetsFilter,
          colorFilter: ColorFilter.mode(
            isDarkMode ? onPrimaryLight : onPrimaryDark,
            BlendMode.srcIn,
          ),
        ),
      );

  Widget buttonLocation(bool isDarkMode, Function()? onPressed) => FloatingActionButton.extended(
        heroTag: 'locationFilter',
        onPressed: onPressed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        backgroundColor: isDarkMode ? surfaceContainerDark : surfaceContainerLight,
        label: SvgPicture.asset(
          Assets.assetsPosition,
          colorFilter: ColorFilter.mode(
            isDarkMode ? onPrimaryLight : onPrimaryDark,
            BlendMode.srcIn,
          ),
        ),
      );

  Widget _buildContent(WidgetRef ref, bool isDarkMode) {
    final mapViewModel = ref.watch(mapProvider);
    final mapsFiltered = ref.watch(mapViewModel.mapsFiltered);
    final searchText = mapViewModel.searchController.text;
    final orderedFields = mapViewModel.orderedFieldsSingleList;

    return ref.watch(mapViewModel.configProviderFamily(tileMap)).when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCA542B))),
          data: (data) => orderedFields.isEmpty
              ? const SizedBox()
              : mapsFiltered.isEmpty && mapViewModel.hasActiveSearch(searchText)
                  ? AtomNoResult(
                      isDarkMode: isDarkMode,
                      query: searchText,
                      text: 'Carte',
                    )
                  : FlutterMap(
                      mapController: mapViewModel.mapController,
                      options: const MapOptions(
                        maxZoom: 20.0,
                        minZoom: 0,
                        initialCenter: LatLng(
                          43.722379709967,
                          7.1527159412457,
                        ),
                      ),
                      children: [
                        mapViewModel.tileLayerOptions,
                        MarkerClusterLayerWidget(
                          options: MarkerClusterLayerOptions(
                            markers: mapViewModel.markers.values.toList(),
                            showPolygon: false,
                            size: const Size(55, 55),
                            builder: (context, markers) => Stack(
                              children: [
                                Align(
                                  child: AtomImage(
                                    imageType: ImageEnum.vectorAssets,
                                    assetPath: Assets.assetsImageMarkerPinlet,
                                    size: const Size(48, 48),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Align(
                                  alignment: const Alignment(0.0, -0.3),
                                  child: AtomText(
                                    data: markers.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      height: 14.06 / 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          error: (error, refs) {
            debugPrint('Error fetching publication maps: $error');
            return Center(
              child: Text(
                'Erreur : $error',
                style: const TextStyle(color: Colors.black),
              ),
            );
          },
        );
  }
}
