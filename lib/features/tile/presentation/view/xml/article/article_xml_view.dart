import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/article/articles_xml_view_model.dart';
import 'widgets/article_xml_view_wrapper.dart';

class ArticleXmlView extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const ArticleXmlView({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<ArticleXmlView> createState() => _ArticleXmlViewState();
}

class _ArticleXmlViewState extends ConsumerState<ArticleXmlView> {
  @override
  void initState() {
    ref.read(articlesXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ArticleXmlViewWrapper(
        withScaffold: false,
        tileXml: widget.tileXml,
      );
}
