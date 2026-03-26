import 'package:flutter/material.dart';

import '../../core/enums/image_enum.dart';
import '../molecules/molecule_content.dart';

class OrganismContentCard extends StatelessWidget {
  const OrganismContentCard({
    required this.backgroundColor,
    required this.thematic,
    required this.chapeau,
    this.base64ImageData,
    this.labelImage,
    this.localImagePath,
    this.imageType = ImageEnum.bitmapAssets,
    this.dateAbove = false,
    this.axis = Axis.vertical,
    this.date,
    this.details,
    this.styleThematic,
    this.styleChapeau,
    this.styleDate,
    this.styleDetails,
    this.sizeImage,
    this.onTap,
    this.searchQuery='',
    this.isDarkMode=true,
    super.key,
  });

  final Color backgroundColor;
  final ImageEnum imageType;
  final String thematic;
  final String? base64ImageData;
  final String? labelImage;
  final String? localImagePath;
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
  final String searchQuery;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
          color: backgroundColor,
          boxShadow: [
            const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 23.2,
            ),
          ],
        ),
        child: MoleculeContent(
          imageType: imageType,
          base64ImageData: base64ImageData,
          labelImage: labelImage,
          localImagePath: localImagePath,
          thematic: thematic,
          chapeau: chapeau,
          styleThematic: styleThematic,
          styleChapeau: styleChapeau,
          styleDate: styleDate,
          styleDetails: styleDetails,
          date: date,
          details: details,
          sizeImage: sizeImage,
          axis: axis,
          onTap: onTap,
          dateAbove: dateAbove,
          searchQuery: searchQuery,
          isDarkMode: isDarkMode,
        ),
      );
}
