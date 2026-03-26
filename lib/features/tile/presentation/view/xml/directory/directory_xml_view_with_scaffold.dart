import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/directory/directories_xml_view_model.dart';
import 'widgets/directory_xml_view_wrapper.dart';

class DirectoryXmlViewWithScaffold extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const DirectoryXmlViewWithScaffold({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<DirectoryXmlViewWithScaffold> createState() => _DirectoryXmlViewWithScaffoldState();
}

class _DirectoryXmlViewWithScaffoldState extends ConsumerState<DirectoryXmlViewWithScaffold> {
  @override
  void initState() {
    ref.read(directoriesXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => DirectoryXmlViewWrapper(
        withScaffold: true,
        tileXml: widget.tileXml,
      );
}
