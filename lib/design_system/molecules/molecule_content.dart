import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../atoms/atom_highlighted_text.dart';
import '../atoms/atom_text.dart';
import '../atoms/atom_upload_image.dart';

class MoleculeContent extends StatelessWidget {
  final ImageEnum imageType;
  final String? base64ImageData;
  final String? labelImage;
  final String? localImagePath;
  final String thematic;
  final String chapeau;
  final Axis axis;
  final String? date;
  final String? details;
  final TextStyle? styleThematic;
  final TextStyle? styleChapeau;
  final TextStyle? styleDate;
  final TextStyle? styleDetails;
  final Size? sizeImage;
  final GestureTapCallback? onTap;
  final bool dateAbove;
  final IconData? uploadIcon;
  final String searchQuery;
  final bool isDarkMode;

  const MoleculeContent({
    required this.thematic,
    required this.chapeau,
    this.base64ImageData,
    this.labelImage,
    this.localImagePath,
    this.imageType = ImageEnum.bitmapAssets,
    this.axis = Axis.vertical,
    this.dateAbove = false,
    this.date,
    this.details,
    this.styleThematic,
    this.styleChapeau,
    this.styleDate,
    this.styleDetails,
    this.sizeImage,
    this.onTap,
    this.uploadIcon,
    this.searchQuery = '',
    this.isDarkMode = true,
    super.key,
  });

  Key get _imageKey => ValueKey('img_${localImagePath ?? base64ImageData ?? labelImage ?? 'empty'}');

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: axis == Axis.vertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (date != null && dateAbove) ...[
                    AtomText(
                      data: date!,
                      style: styleDate ??
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: isDarkMode ? primaryDark : primaryLight,
                              ),
                    ),
                    16.ph,
                  ],
                  Material(
                    elevation: 4,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AtomUploadImage(
                        key: _imageKey,
                        labelImage: labelImage,
                        base64ImageData: base64ImageData,
                        localImagePath: localImagePath,
                        fit: BoxFit.cover,
                        width: sizeImage?.width ?? double.infinity,
                        height: sizeImage?.height ?? 185,
                        uploadIcon: uploadIcon,
                      ),
                    ),
                  ),
                  15.ph,
                  if (date != null && !dateAbove) ...[
                    AtomHighlightedText(
                      text: date!,
                      searchQuery: searchQuery,
                      style: styleDate ??
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: isDarkMode ? primaryDark : primaryLight,
                              ),
                      isDarkMode: isDarkMode,
                      maxLines: 2,
                    ),
                    5.ph,
                  ],
                  AtomHighlightedText(
                    text: thematic,
                    searchQuery: searchQuery,
                    style: styleThematic ?? Theme.of(context).textTheme.titleMedium!,
                    isDarkMode: isDarkMode,
                  ),
                  15.ph,
                  AtomHighlightedText(
                    text: chapeau,
                    searchQuery: searchQuery,
                    style: styleChapeau ?? Theme.of(context).textTheme.titleLarge!,
                    isDarkMode: isDarkMode,
                    maxLines: 3,
                  ),
                  if (details != null) ...[
                    20.ph,
                    AtomHighlightedText(
                      text: details!,
                      searchQuery: searchQuery,
                      style: styleDetails ?? Theme.of(context).textTheme.bodyMedium!,
                      isDarkMode: isDarkMode,
                      maxLines: 4,
                    ),
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AtomUploadImage(
                    key: _imageKey,
                    labelImage: labelImage,
                    base64ImageData: base64ImageData,
                    localImagePath: localImagePath,
                    width: sizeImage?.width ?? double.infinity,
                    height: sizeImage?.height ?? 185,
                    uploadIcon: uploadIcon,
                    fit: BoxFit.cover,
                  ),
                  16.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (date != null) ...[
                          AtomHighlightedText(
                            text: date!,
                            searchQuery: searchQuery,
                            style: styleDate ?? Theme.of(context).textTheme.titleLarge!,
                            isDarkMode: isDarkMode,
                          ),
                          5.ph,
                        ],
                        AtomHighlightedText(
                          text: thematic,
                          searchQuery: searchQuery,
                          style: styleThematic ?? Theme.of(context).textTheme.titleMedium!,
                          isDarkMode: isDarkMode,
                        ),
                        15.ph,
                        AtomHighlightedText(
                          text: chapeau,
                          searchQuery: searchQuery,
                          style: styleChapeau ?? Theme.of(context).textTheme.titleLarge!,
                          isDarkMode: isDarkMode,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      );
}
