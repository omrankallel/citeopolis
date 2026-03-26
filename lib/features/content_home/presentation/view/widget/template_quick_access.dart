import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import '../../../../../core/core.dart';
import '../../../../../core/extensions/tile_extension.dart';
import '../../../../../core/utils/icon_picto_helper.dart';
import '../../../../../design_system/molecules/molecule_stone.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../../../home/domain/modals/content_home/quick_access.dart';
import '../../../../home/presentation/viewmodel/home_view_model.dart';

class TemplateQuickAccess extends StatelessWidget {
  final bool isLast;

  final QuickAccess? quickAccess;

  const TemplateQuickAccess({required this.quickAccess, required this.isLast, super.key});

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          final String searchText = ref.read(ref.watch(homeProvider).searchText.notifier).state;
          final rows = quickAccess?.rows;
          if (rows == null || rows.isEmpty) return const SizedBox();
          return Column(
            children: [
              20.ph,
              WallLayout(
                stones: rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final sizeQuickAccess = data.sizeQuickAccess ?? '1*1';
                  final separatorChar = sizeQuickAccess.contains('*') ? '*' : 'x';
                  final sizeParts = sizeQuickAccess.split(separatorChar);
                  final width = int.tryParse(sizeParts[0]) ?? 1;
                  final height = int.tryParse(sizeParts.length > 1 ? sizeParts[1] : '1') ?? 1;

                  final background = Helpers.hexToColor((data.colorBackground ?? '').isNotEmpty ? data.colorBackground! : '#00000000');
                  final borderColorParsed = Helpers.hexToColor((data.borderColor ?? '').isNotEmpty ? data.borderColor! : '#00000000');
                  final colorText = Helpers.hexToColor((data.titleColor ?? '').isNotEmpty ? data.titleColor! : '#00000000');

                  final borderRadius = double.tryParse(data.radiusBorder ?? '0') ?? 0.0;
                  final borderWidth = double.tryParse(data.edgeBorder ?? '0') ?? 0.0;

                  final pictogram = data.pictogram ?? '';
                  final localImagePath = data.localPath ?? '';
                  final pictogramName = data.pictogramName ?? '';
                  final text = data.title ?? '';

                  IconData? pictogramIcon;
                  if (pictogram.isEmpty) {
                    final int indexIcon = int.parse(data.automaticPictogram ?? '0');
                    pictogramIcon = listPicto[indexIcon].icon;
                  }

                  return Stone(
                    id: index,
                    width: width,
                    height: height,
                    child: MoleculeStone(
                      background: background,
                      text: text,
                      borderRadius: borderRadius,
                      borderColor: borderColorParsed,
                      borderWidth: borderWidth,
                      base64ImageData: pictogram,
                      colorText: colorText,
                      height: height,
                      iconData: pictogramIcon,
                      localImagePath: localImagePath,
                      labelImage: pictogramName,
                      onTap: () async {
                        if ((data.typeLink ?? '') == '1') {
                          await context.redirectToTile(ref, data.tile ?? '', true);
                        } else if ((data.typeLink ?? '') == '2') {
                          NavigationService.go(context,ref,Paths.urlTileWithScaffold, extra: data.urlLink ?? '');
                        }
                      },
                      isDarkMode: isDarkMode,
                      searchQuery: searchText,
                    ),
                  );
                }).toList(),
                layersCount: 3,
              ),
              if (isLast) ...[
                40.ph,
              ] else ...[
                40.ph,
                const Divider(color: Color(0XFFCAC4D0), indent: 0, endIndent: 0, thickness: 1),
                40.ph,
              ],
            ],
          );
        },
      );
}
