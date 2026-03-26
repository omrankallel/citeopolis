import 'package:flutter/material.dart';

import '../../../domain/modals/tile_content.dart';
import 'widgets/content_tile_view_wrapper.dart';


class ContentTileView extends StatelessWidget {
  final TileContent tileContent;

  const ContentTileView({
    required this.tileContent,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ContentTileViewWrapper(
    withScaffold: false,
    tileContent: tileContent,
  );
}
