import 'package:flutter/material.dart';

import '../../../domain/modals/tile_quick_access.dart';
import 'widgets/quick_access_tile_view_wrapper.dart';

class QuickAccessTileView extends StatelessWidget {
  final TileQuickAccess tileQuickAccess;

  const QuickAccessTileView({
    required this.tileQuickAccess,
    super.key,
  });

  @override
  Widget build(BuildContext context) => QuickAccessTileViewWrapper(
    withScaffold: false,
    tileQuickAccess: tileQuickAccess,
  );
}
