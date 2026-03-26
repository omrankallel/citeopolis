import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/publication/publications_xml_view_model.dart';
import 'widgets/publication_xml_view_wrapper.dart';

class PublicationXmlViewWithScaffold extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const PublicationXmlViewWithScaffold({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<PublicationXmlViewWithScaffold> createState() => _PublicationXmlViewWithScaffoldState();
}

class _PublicationXmlViewWithScaffoldState extends ConsumerState<PublicationXmlViewWithScaffold> {
  @override
  void initState() {
    ref.read(publicationsXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PublicationXmlViewWrapper(
        withScaffold: true,
        tileXml: widget.tileXml,
      );
}
