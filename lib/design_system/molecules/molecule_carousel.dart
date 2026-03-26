import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../atoms/atom_highlighted_text.dart';
import '../atoms/atom_indicator.dart';
import '../atoms/atom_upload_image.dart';

class MoleculeCarousel extends StatelessWidget {
  const MoleculeCarousel({
    required this.index,
    required this.isDarkMode,
    required this.imageNameList,
    required this.titleList,
    required this.imageList,
    required this.localPathList,
    this.controllerCarousel,
    this.onPageChanged,
    this.onTap,
    this.searchQuery = '',
    super.key,
  });

  final int index;
  final bool isDarkMode;
  final CarouselSliderController? controllerCarousel;
  final List<String> titleList;
  final List<String?> imageList;
  final List<String?> imageNameList;
  final List<String?> localPathList;
  final Function(int index, CarouselPageChangedReason reason)? onPageChanged;
  final Function(int)? onTap;
  final String searchQuery;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: InkWell(
                onTap: () {
                  if (onTap != null) onTap!.call(index);
                },
                child: CarouselSlider(
                  carouselController: controllerCarousel,
                  items: [
                    for (int i = 0; i < imageList.length; i++)
                      KeyedSubtree(
                        key: ValueKey('carousel_item_${localPathList[i] ?? imageList[i] ?? i}'),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AtomUploadImage(
                              key: ValueKey('img_${localPathList[i] ?? imageList[i] ?? i}'),
                              labelImage: imageNameList[i],
                              base64ImageData: imageList[i],
                              localImagePath: localPathList[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                  ],
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    height: 250,
                    viewportFraction: 1,
                    onPageChanged: onPageChanged,
                  ),
                ),
              ),
            ),
            20.ph,
            AtomHighlightedText(
              text: titleList[index],
              searchQuery: searchQuery,
              style: Theme.of(context).textTheme.headlineSmall!,
              isDarkMode: isDarkMode,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
            20.ph,
            Row(
              children: [
                for (int i = 0; i < imageList.length; i++)
                  InkWell(
                    onTap: () {
                      controllerCarousel!.animateToPage(i);
                    },
                    child: AtomIndicator(
                      width: index == i ? 48.0 : 12.0,
                      color: index == i
                          ? isDarkMode
                              ? primaryDark
                              : primaryLight
                          : isDarkMode
                              ? primaryLight
                              : primaryDark,
                      borderColor: isDarkMode ? primaryDark : primaryLight,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
}
