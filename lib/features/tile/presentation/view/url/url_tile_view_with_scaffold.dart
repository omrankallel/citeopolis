import 'package:flutter/material.dart';

import 'widgets/url_tile_view_wrapper.dart';

class UrlTileViewWithScaffold extends StatelessWidget {
  final String url;
  final bool isTile;

  const UrlTileViewWithScaffold({
    required this.url,
    required this.isTile,
    super.key,
  });

  @override
  Widget build(BuildContext context) => UrlTileViewWrapper(
        withScaffold: true,
        url: url,
        isTile: isTile,
      );
}
