import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import '../../core/theme/theme_provider.dart';
import '../../router/routes.dart';
import '../molecules/molecule_stone.dart';

class OrganismStoneList {
  List<Stone> buildStonesList(WidgetRef ref, List<Map<String, Object?>> listAccessRapid) => listAccessRapid.map((data) {
        final bool isDarkMode = ref.watch(themeProvider).isDarkMode;
        final int width = data['width'] as int;
        final int height = data['height'] as int;
        final Color colorLight = data['colorLight'] as Color;
        final Color colorDark = data['colorDark'] as Color;
        final int borderRadius = data['borderRadius'] as int;
        final int borderWidth = data['borderWidth'] as int;
        final Color? borderColorLight = data['borderColorLight'] as Color?;
        final Color? borderColorDark = data['borderColorDark'] as Color?;
        final String icon = data['icon'] as String;
        final Color colorIconLight = data['colorIconLight'] as Color;
        final Color colorIconDark = data['colorIconDark'] as Color;
        final String text = data['text'] as String;
        final Color colorTextLight = data['colorTextLight'] as Color;
        final Color colorTextDark = data['colorTextDark'] as Color;

        return Stone(
          id: listAccessRapid.indexOf(data),
          width: width,
          height: height,
          child: MoleculeStone(
            background: isDarkMode ? colorDark : colorLight,
            text: text,
            borderRadius: borderRadius.toDouble(),
            borderColor: isDarkMode ? borderColorDark : borderColorLight,
            borderWidth: borderWidth.toDouble(),
            icon: icon,
            colorIcon: isDarkMode ? colorIconDark : colorIconLight,
            colorText: isDarkMode ? colorTextDark : colorTextLight,
            onTap: text == 'Actualités'
                ? () {
                   // ref.watch(contentDetailProvider).contentType = ContentEnum.news;
              goRouter.go(Paths.contentDetail);
                  }
                : text == 'Sorties et loisirs'
                    ? () {
                      //  ref.watch(contentDetailProvider).contentType = ContentEnum.events;
              goRouter.go(Paths.contentDetail);
                      }
                    : null,
          ),
        );
      }).toList();
}
