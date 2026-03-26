import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/core.dart';
import '../../../../../core/extensions/tile_extension.dart';
import '../../../../../design_system/molecules/molecule_carousel.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../../home/domain/modals/content_home/carrousel.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../viewmodel/content_home_view_model.dart';

class OrganismCarousel extends StatelessWidget {
  final bool isFirst;
  final Carrousel? carrousel;
  final int selectedIndex;

  const OrganismCarousel({
    required this.selectedIndex,
    required this.carrousel,
    required this.isFirst,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          final contentHomeViewModel = ref.watch(contentHomeProvider);
          final sections = ref.watch(contentHomeViewModel.buildPageFiltered).sections ?? [];

          if (selectedIndex >= sections.length) return const SizedBox.shrink();

          final repeaterList = sections[selectedIndex].carrousel?.carrouselRepeater ?? [];
          if (repeaterList.isEmpty) return const SizedBox.shrink();

          final String id = sections[selectedIndex].id ?? '';

          return Column(
            children: [
              if (!isFirst) 20.ph,
              MoleculeCarousel(
                index: ref.watch(contentHomeViewModel.currentIndexCarousel.select((value) => value[id] ?? 0)),
                imageList: repeaterList.map((e) => e.repPictoImg ?? '').toList(),
                titleList: repeaterList.map((e) => e.repTitle ?? '').toList(),
                imageNameList: repeaterList.map((e) => (e.repPictoImg ?? '').split('/').last).toList(),
                localPathList: repeaterList.map((e) => e.localPath ?? '').toList(),
                isDarkMode: ref.watch(themeProvider).isDarkMode,
                controllerCarousel: ref.watch(contentHomeViewModel.controllerCarouselList)[id] ?? CarouselSliderController(),
                onPageChanged: (index, reason) => contentHomeViewModel.changeCurrentIndexCarousel(selectedIndex, index, ref),
                onTap: (index) async {
                  if (index >= repeaterList.length) return;
                  final repeater = repeaterList[index];
                  if ((repeater.repTypeLink ?? '') == '1') {
                    await context.redirectToTile(ref, repeater.repTile ?? '', true);
                  } else if ((repeater.repTypeLink ?? '') == '2') {
                    NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: repeater.repUrl ?? '');
                  }
                },
                searchQuery: ref.read(ref.watch(homeProvider).searchText.notifier).state,
              ),
              60.ph,
            ],
          );
        },
      );
}
