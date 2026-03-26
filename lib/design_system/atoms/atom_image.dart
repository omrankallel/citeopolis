import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/enums/enums.dart' show ImageEnum;

class AtomImage extends StatelessWidget {
  AtomImage({
    required this.imageType,
    this.assetPath,
    this.imageUrl,
    this.size,
    this.borderRadius = BorderRadius.zero,
    this.colorFilter,
    BoxFit? fit,
    super.key,
  }) : fit = fit ?? BoxFit.cover {
    assert(
      _isValidImageParameters(),
      'Please provide the required parameters based on imageType.',
    );
  }

  bool _isValidImageParameters() {
    switch (imageType) {
      case ImageEnum.bitmapAssets:
      case ImageEnum.vectorAssets:
        return assetPath != null;
      case ImageEnum.bitmapNetwork:
      case ImageEnum.vectorNetwork:
        return imageUrl != null;
      default:
        return false;
    }
  }

  final ImageEnum imageType;
  final String? imageUrl;
  final String? assetPath;
  final BoxFit fit;
  final Size? size;
  final BorderRadiusGeometry borderRadius;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    switch (imageType) {
      case ImageEnum.vectorAssets:
        imageWidget = SvgPicture.asset(
          assetPath!,
          width: size?.width,
          height: size?.height,
          fit: fit,
          colorFilter: colorFilter,
        );
        break;
      case ImageEnum.vectorNetwork:
        imageWidget = SvgPicture.network(
          imageUrl!,
          width: size?.width,
          height: size?.height,
          fit: fit,
          colorFilter: colorFilter,
        );
        break;
      case ImageEnum.bitmapNetwork:
        imageWidget = Image.network(
          imageUrl!,
          width: size?.width,
          height: size?.height,
          fit: fit,
        );
        break;
      case ImageEnum.bitmapAssets:
      default:
        imageWidget = Image.asset(
          assetPath!,
          width: size?.width,
          height: size?.height,
          fit: fit,
        );
        break;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: imageWidget,
    );
  }
}
