import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/enums/enums.dart' show ImageEnum;

class CustomImageWithCloseIcon extends StatelessWidget {
  final ImageEnum imageType;
  final Widget iconClose;
  final BoxFit fit;
  final Size size;

  final String? assetPath;
  final String? imageUrl;
  final IconData? iconData;
  final VoidCallback? onClose;
  final bool showIconClose;

  CustomImageWithCloseIcon({
    required this.imageType,
    this.showIconClose = true,
    this.assetPath,
    this.imageUrl,
    this.iconData,
    this.onClose,
    Widget? iconClose,
    BoxFit? fit,
    Size? size,
    super.key,
  })  : iconClose = iconClose ??
            const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
        fit = fit ?? BoxFit.cover,
        size = size ?? const Size(300, 200) {
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
      case ImageEnum.icon:
        return iconData != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    switch (imageType) {
      case ImageEnum.vectorAssets:
        imageWidget = SvgPicture.asset(
          assetPath!,
          width: size.width,
          height: size.height,
          fit: fit,
        );
        break;
      case ImageEnum.vectorNetwork:
        imageWidget = SvgPicture.network(
          imageUrl!,
          width: size.width,
          height: size.height,
          fit: fit,
        );
        break;
      case ImageEnum.icon:
        imageWidget = Icon(
          iconData,
          size: size.width,
          color: Colors.blue,
        );
        break;
      case ImageEnum.bitmapNetwork:
        imageWidget = Image.network(
          imageUrl!,
          width: size.width,
          height: size.height,
          fit: fit,
        );
        break;
      case ImageEnum.bitmapAssets:
      default:
        imageWidget = Image.asset(
          assetPath!,
          width: size.width,
          height: size.height,
          fit: fit,
        );
        break;
    }

    return Stack(
      children: [
        imageWidget,
        if (showIconClose)
          Align(
            alignment: const Alignment(0.9, -0.9),
            child: GestureDetector(
              onTap: onClose ?? () {},
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(5),
                child: iconClose,
              ),
            ),
          ),
      ],
    );
  }
}
