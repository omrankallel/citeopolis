import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/modals/tile_xml.dart';
import '../../../viewmodel/xml/event/events_xml_view_model.dart';
import 'widgets/event_xml_view_wrapper.dart';

class EventsXmlView extends ConsumerStatefulWidget {
  final TileXml tileXml;

  const EventsXmlView({
    required this.tileXml,
    super.key,
  });

  @override
  ConsumerState<EventsXmlView> createState() => _EventsXmlViewState();
}

class _EventsXmlViewState extends ConsumerState<EventsXmlView> {
  @override
  void initState() {
    ref.read(eventsXmlProvider).isInitialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => EventXmlViewWrapper(
        withScaffold: false,
        tileXml: widget.tileXml,
      );
}
