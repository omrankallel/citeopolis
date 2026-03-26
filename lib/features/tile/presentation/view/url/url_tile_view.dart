import 'package:flutter/material.dart';

import 'widgets/url_tile_view_wrapper.dart';


class UrlTileView extends StatelessWidget {
  final String url;

  const UrlTileView({
    required this.url,
    super.key,
  });

  @override
  Widget build(BuildContext context) => UrlTileViewWrapper(
    withScaffold: false,
    url: url,
  );
}
