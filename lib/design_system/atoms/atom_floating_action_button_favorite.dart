import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/constants/assets.dart';
import '../../core/constants/colors.dart';

class AtomFloatingActionButtonFavorite extends StatelessWidget {
  final VoidCallback onPressed;
  final String assetPath;
  final bool isDarkMode;
  final String heroTag;
  final bool isFavorite;

  const AtomFloatingActionButtonFavorite({
    required this.heroTag,
    required this.onPressed,
    required this.assetPath,
    required this.isDarkMode,
    required this.isFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        backgroundColor: isFavorite
            ? isDarkMode
                ? primaryDark
                : primaryLight
            : isDarkMode
                ? surfaceContainerDark
                : surfaceContainerLight,
        label: SvgPicture.asset(
          isFavorite
              ? isDarkMode
                  ? Assets.assetsImageSaveDark
                  : Assets.assetsImageSaveLight
              : isDarkMode
                  ? Assets.assetsImageUnsavedDark
                  : Assets.assetsImageUnsavedLight,
        ),
      );
}
