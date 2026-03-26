import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/article/articles_xml_view_model.dart';
import 'widgets/article_xml_view_wrapper.dart';

class ArticleXmlViewWithScaffold extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const ArticleXmlViewWithScaffold({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<ArticleXmlViewWithScaffold> createState() => _ArticleXmlViewWithScaffoldState();
}

class _ArticleXmlViewWithScaffoldState extends ConsumerState<ArticleXmlViewWithScaffold> {
  @override
  void initState() {
    ref.read(articlesXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ArticleXmlViewWrapper(
        withScaffold: true,
        tileXml: widget.tileXml,
      );
}
