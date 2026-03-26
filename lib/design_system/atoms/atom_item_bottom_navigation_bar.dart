import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/webmaster../../../../../core/core.dart';
import 'atom_upload_image.dart';

class AtomItemBottomNavigationBar extends StatelessWidget {
  final IconData? iconData;
  final String text;
  final int index;
  final int currentIndex;
  final bool isActive;
  final bool isImage;
  final String? labelImage;
  final String? base64ImageData;
  final String? localImagePath;
  final GestureTapCallback? onTap;

  const AtomItemBottomNavigationBar({
    required this.text,
    required this.index,
    required this.currentIndex,
    this.iconData,
    this.isActive = true,
    this.isImage = false,
    this.labelImage,
    this.base64ImageData,
    this.localImagePath,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, widget) => Container(
      width: MediaQuery.of(context).size.width / 5,
      color: ref.watch(themeProvider).isDarkMode ? surfaceContainerDark : surfaceContainerLight,
      padding: const EdgeInsets.only(bottom: 15, top: 15),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              decoration: currentIndex == index
                  ? BoxDecoration(
                color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                borderRadius: BorderRadius.circular(50),
              )
                  : null,
              child: isActive
                  ? isImage
                  ? AtomUploadImage(
                labelImage: labelImage,
                base64ImageData: base64ImageData,
                localImagePath: localImagePath,
              )
                  : Icon(
                iconData,
                color: currentIndex == index
                    ? ref.watch(themeProvider).isDarkMode
                    ? onPrimaryDark
                    : onPrimaryLight
                    : ref.watch(themeProvider).isDarkMode
                    ? onSurfaceDark
                    : onSurfaceLight,
              )
                  : null,
            ),
            5.ph,
            SizedBox(
              height: 20,
              child: isActive
                  ? Text(
                text,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: currentIndex == index
                      ? ref.watch(themeProvider).isDarkMode
                      ? primaryDark
                      : primaryLight
                      : ref.watch(themeProvider).isDarkMode
                      ? onSurfaceDark
                      : onSurfaceLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}
