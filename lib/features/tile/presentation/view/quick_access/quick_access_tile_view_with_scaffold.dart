import 'package:flutter/material.dart';

import '../../../domain/modals/tile_quick_access.dart';
import 'widgets/quick_access_tile_view_wrapper.dart';

class QuickAccessTileViewWithScaffold extends StatelessWidget {
  final TileQuickAccess tileQuickAccess;

  const QuickAccessTileViewWithScaffold({
    required this.tileQuickAccess,
    super.key,
  });

  @override
  Widget build(BuildContext context) => QuickAccessTileViewWrapper(
        withScaffold: true,
        tileQuickAccess: tileQuickAccess,
      );
}
