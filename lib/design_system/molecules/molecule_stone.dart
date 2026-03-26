import 'package:flutter/material.dart';

import '../atoms/atom_highlighted_text.dart';
import '../atoms/atom_upload_image.dart';

class MoleculeStone extends StatelessWidget {
  const MoleculeStone({
    required this.background,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.text,
    required this.colorText,
    this.icon,
    this.colorIcon,
    this.base64ImageData,
    this.labelImage,
    this.localImagePath,
    this.onTap,
    this.height = 1,
    this.iconData,
    this.searchQuery = '',
    this.isDarkMode = true,
    super.key,
  });

  final Color background;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final String? icon;
  final String? base64ImageData;
  final String? labelImage;
  final String? localImagePath;
  final String text;
  final Color? colorIcon;
  final Color colorText;
  final GestureTapCallback? onTap;
  final int height;
  final IconData? iconData;
  final String searchQuery;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor == null || borderWidth == 0 ? null : Border.all(color: borderColor!, width: borderWidth),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconData != null
                  ? Icon(
                      iconData,
                      size: 48,
                    )
                  : AtomUploadImage(
                      labelImage: labelImage,
                      base64ImageData: base64ImageData,
                      localImagePath: localImagePath,
                      height: 48,
                      width: 48,
                    ),
              const SizedBox(height: 6),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: AtomHighlightedText(
                    text: text,
                    searchQuery: searchQuery,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: isColorYellowZone(colorText) && isColorYellowZone(background) ? Colors.red : colorText, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: height > 1 ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

bool isColorYellowZone(Color color) {
  final HSLColor hsl = HSLColor.fromColor(color);
  final double hue = hsl.hue; // Hue is between 0 and 360
  return hue >= 45 && hue <= 65;
}
