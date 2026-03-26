import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'atom_image.dart';
import 'atom_text.dart';

class AtomEmpty extends StatelessWidget {
  const AtomEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: AtomImage(
                  imageType: ImageEnum.bitmapAssets,
                  assetPath: Assets.assetsImageEmpty,
                ),
              ),
              const AtomText(
                data: 'Aucune donnée à afficher',
                style: TextStyle(
                  color: outlineDark,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
}
