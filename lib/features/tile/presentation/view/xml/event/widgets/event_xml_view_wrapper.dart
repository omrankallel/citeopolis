import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../../../design_system/atoms/atom_highlighted_text.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../design_system/atoms/atom_text_icon.dart';
import '../../../../../../../design_system/atoms/atom_upload_image.dart';
import '../../../../../../../router/navigation_service.dart';
import '../../../../../../../router/routes.dart';
import '../../../../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../../../domain/modals/tile_xml.dart';
import '../../../../../domain/modals/xml/xml_event.dart';
import '../../../../viewmodel/xml/event/events_xml_view_model.dart';

class EventXmlViewWrapper extends StatelessWidget {
  final bool withScaffold;
  final TileXml tileXml;

  const EventXmlViewWrapper({
    required this.tileXml,
    required this.withScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final eventsXmlViewModel = ref.watch(eventsXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          eventsXmlViewModel.initializeEvents(ref, tileXml,withScaffold);
          return withScaffold ? _buildWithScaffold(ref, isDarkMode, context) : _buildWithoutScaffold(ref, isDarkMode, context);
        },
      );

  Widget _buildWithScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final eventsXmlViewModel = ref.watch(eventsXmlProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: eventsXmlViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawerEnableOpenDragGesture: false,
        endDrawer: eventsXmlViewModel.atomEndDrawerEvent(ref, eventsXmlViewModel.scaffoldKey, isDarkMode),
        appBar: AtomAppBarWithSearch(
          searchController: eventsXmlViewModel.searchController,
          isDarkMode: isDarkMode,
          searchHint: 'Rechercher ...',
          backgroundColor: Theme.of(context).primaryColor,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => NavigationService.back(context, ref),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
              ),
            ),
          ),
          onSearchChanged: (text) => eventsXmlViewModel.onSearchTextChanged(ref, text),
          onSearchCleared: () => eventsXmlViewModel.onSearchTextChanged(ref, ''),
          actions: [
            NotificationIconBadge(
              iconData: Icons.notifications_none_sharp,
              onTap: () => NavigationService.push(context, ref, Paths.notifications),
            ),
            25.pw,
            InkWell(
              onTap: () {},
              child: const WidgetPopupMenu(),
            ),
            20.pw,
          ],
        ),
        body: Column(
          children: [
            20.ph,
            _buildHeader(ref, eventsXmlViewModel.scaffoldKey, isDarkMode, context),
            26.ph,
            Expanded(child: _buildContent(ref, isDarkMode)),
          ],
        ),
      ),
    );
  }
  Widget _buildWithoutScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final homeViewModel = ref.watch(homeProvider);
    return Column(
      children: [
        20.ph,
        _buildHeader(ref, homeViewModel.scaffoldKey, isDarkMode, context),
        26.ph,
        Expanded(child: _buildContent(ref, isDarkMode)),
      ],
    );
  }


  Widget _buildHeader(WidgetRef ref, GlobalKey<ScaffoldState> scaffoldKey, bool isDarkMode, BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      children: [
        AtomHighlightedText(
          text: 'Événements',
          searchQuery: '',
          style: Theme.of(context).textTheme.headlineLarge!,
          isDarkMode: isDarkMode,
        ),
        const Spacer(),
        InkWell(
          onTap: () => scaffoldKey.currentState?.openEndDrawer(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF757579)),
            ),
            child: AtomTextIcon(
              data: 'Filtrer',
              iconData: Icons.sort,
              spacing: 8,
              style: Theme.of(context).textTheme.labelLarge,
              sizeIcon: 18,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildContent(WidgetRef ref, bool isDarkMode) {
    final eventsXmlViewModel = ref.watch(eventsXmlProvider);
    final filteredEvents = ref.watch(eventsXmlViewModel.eventsFiltered);
    final orderedFields = eventsXmlViewModel.orderedFieldsSingleList;

    final searchText = withScaffold ? eventsXmlViewModel.searchController.text : ref.watch(homeProvider).searchController.text;

    return ref.watch(eventsXmlViewModel.configProviderFamily(tileXml)).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFCA542B)),
          ),
          data: (_) => orderedFields.isEmpty
              ? const SizedBox()
              : filteredEvents.isEmpty && eventsXmlViewModel.hasActiveSearch(searchText)
                  ? AtomNoResult(
                      isDarkMode: isDarkMode,
                      query: searchText,
                      text: 'Event',
                    )
                  : _buildEventsList(ref, filteredEvents, searchText, isDarkMode),
          error: (error, _) => Center(
            child: Text(
              'Erreur : $error',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
  }

  Widget _buildEventsList(WidgetRef ref, List<Event> filteredEvents, String searchText, bool isDarkMode) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                itemCount: filteredEvents.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return _buildEventCard(context, ref, event, searchText, isDarkMode);
                },
                separatorBuilder: (context, index) => 32.ph,
              ),
              50.ph,
            ],
          ),
        ),
      );

  Widget _buildEventCard(BuildContext context, WidgetRef ref, Event event, String searchText, bool isDarkMode) {
    final eventsXmlViewModel = ref.watch(eventsXmlProvider);

    return InkWell(
      onTap: () {
        NavigationService.push(
          context,
          ref,
          Paths.detailEventsXml ,
          extra: {
            'tileXml': tileXml,
            'eventXml': event,
            'allEvents': eventsXmlViewModel.events,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: ref.watch(themeProvider).isDarkMode ? onPrimaryDark : onPrimaryLight,
          boxShadow: [
            const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 23.2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildEventFields(context, ref, event, isDarkMode, searchText),
        ),
      ),
    );
  }

  List<Widget> _buildEventFields(BuildContext context, WidgetRef ref, Event event, bool isDarkMode, String searchText) {
    final eventsXmlViewModel = ref.watch(eventsXmlProvider);
    final orderedFields = eventsXmlViewModel.orderedFieldsSingleList;
    final widgets = <Widget>[];

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (event.title.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: event.title,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleLarge!,
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              15.ph,
            ]);
          }
          break;

        case 'mainimage':
          if (event.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AtomUploadImage(
                    base64ImageData: event.mainImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                ),
              ),
              15.ph,
            ]);
          }
          break;

        case 'category':
          if (event.category.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: event.category,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!,
                isDarkMode: isDarkMode,
              ),
              15.ph,
            ]);
          }
          break;

        case 'eventenddate':
          break;
        case 'eventstartdate':
          String date = '';
          if (event.eventStartDate.isNotEmpty && event.eventEndDate.isNotEmpty) {
            date = 'Du ${_formatDate(event.eventStartDate)} au ${_formatDate(event.eventEndDate)}';
          } else if (event.eventStartDate.isNotEmpty) {
            date = 'Le ${_formatDate(event.eventStartDate)}';
          }
          if (date.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: date,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: isDarkMode ? primaryDark : primaryLight,
                    ),
                isDarkMode: isDarkMode,
              ),
              15.ph,
            ]);
          }
          break;
      }
    }

    return widgets;
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }
}
