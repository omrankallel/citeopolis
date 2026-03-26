import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/event/events_xml_view_model.dart';
import 'widgets/event_xml_view_wrapper.dart';

class EventsXmlViewWithScaffold extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const EventsXmlViewWithScaffold({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<EventsXmlViewWithScaffold> createState() => _EventsXmlViewWithScaffoldState();
}

class _EventsXmlViewWithScaffoldState extends ConsumerState<EventsXmlViewWithScaffold> {
  @override
  void initState() {
    ref.read(eventsXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => EventXmlViewWrapper(
        withScaffold: true,
        tileXml: widget.tileXml,
      );
}
