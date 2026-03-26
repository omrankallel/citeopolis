import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/directory/directories_xml_view_model.dart';
import 'widgets/directory_xml_view_wrapper.dart';

class DirectoryXmlView extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const DirectoryXmlView({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<DirectoryXmlView> createState() => _DirectoryXmlViewState();
}

class _DirectoryXmlViewState extends ConsumerState<DirectoryXmlView> {
  @override
  void initState() {
    ref.read(directoriesXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => DirectoryXmlViewWrapper(
        withScaffold: false,
        tileXml: widget.tileXml,
      );
}
