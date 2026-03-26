import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_event.dart';

final eventsXmlProvider = ChangeNotifierProvider.autoDispose((ref) => EventsXmlProvider());

class EventsXmlProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();

  bool isInitialized = false;

  List<Event> events = [];
  final eventsFiltered = StateProvider<List<Event>>((ref) => []);

  List<TileXmlId> orderedFieldsSingleList = [];

  final thematics = StateProvider<List<String>>((ref) => []);
  final selectedList = StateProvider<List<bool>>((ref) => []);

  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  bool hasActiveSearch(String searchText) => searchText.isNotEmpty;

  Future<void> initializeEvents(WidgetRef ref, TileXml tileXml, bool withScaffold) async {
    if (isInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isInitialized = true;
      if (withScaffold) {
        searchController.clear();
      } else {
        ref.read(homeProvider).searchController.clear();
      }

      events.clear();
      ref.read(eventsFiltered.notifier).state.clear();
      orderedFieldsSingleList.clear();

      ref.read(thematics.notifier).state.clear();
      ref.read(selectedList.notifier).state.clear();
      startDate.clear();
      endDate.clear();
    });
  }

  final configProviderFamily = FutureProvider.family.autoDispose<void, TileXml>((ref, xml) async {
    final eventsXmlViewModel = ref.read(eventsXmlProvider);

    try {
      final url = xml.results?.urlTile ?? '';
      final numberElement = int.parse(xml.results?.numberElement ?? '0');
      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlEvents = <XmlElement>[];
        for (final eventNode in document.findAllElements('event')) {
          allXmlEvents.add(eventNode);
        }

        final config = xml.results;

        final fieldsSingleList = eventsXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        eventsXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isNotEmpty) {
          final List<Event> listEvents = allXmlEvents.map((xmlElement) => Event.fromXml(xmlElement)).toList();

          final uniqueCategories = <String>{};
          for (final event in listEvents) {
            if (event.category.isNotEmpty) {
              uniqueCategories.add(event.category);
            }
          }

          final sortedCategories = uniqueCategories.toList()..sort();
          ref.read(eventsXmlViewModel.thematics.notifier).state = sortedCategories;
          ref.read(eventsXmlViewModel.selectedList.notifier).state = List.generate(sortedCategories.length, (index) => false);

          eventsXmlViewModel.events = listEvents.take(numberElement).toList();
          ref.read(eventsXmlViewModel.eventsFiltered.notifier).state = listEvents.take(numberElement).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching XML configuration: $e');
    }
  });

  List<TileXmlId> getVisibleOrderItems(List<TileXmlId>? idsList) => idsList?.where((e) => e.status == 1).toList() ?? [];

  Future<void> applyAllFilters(WidgetRef ref, String search) async {
    final searchText = search.trim().toLowerCase();

    final selectedStates = ref.read(selectedList);
    final allThematics = ref.read(thematics);

    final selectedThematics = <String>[];
    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedThematics.add(allThematics[i].toLowerCase());
      }
    }

    List<Event> result = List.from(events);

    if (selectedThematics.isNotEmpty) {
      result = result.where((event) => selectedThematics.contains(event.category.toLowerCase())).toList();
    }

    if (searchText.isNotEmpty) {
      result = result.where((event) => _matchesSearchQuery(event, searchText)).toList();
    }

    final startDateText = startDate.text.trim();
    final endDateText = endDate.text.trim();

    if (startDateText.isNotEmpty || endDateText.isNotEmpty) {
      result = result.where((event) => _isEventWithinDateRange(event.pubDate, startDateText, endDateText)).toList();
    }

    ref.read(eventsFiltered.notifier).state = result;
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    await applyAllFilters(ref, text);
  }

  bool _matchesSearchQuery(Event event, String query) {
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      event.title,
      event.category,
      event.summary,
      event.content,
      event.imageCaption,
      event.mainImage,
      event.pubDate,
      event.updateDate,
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == event.content) {
          fieldContent = _cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == event.mainImage && field.isNotEmpty) {
          final fileName = field.split('/').last.toLowerCase();
          final fileNameWithoutExtension = fileName.split('.').first;

          if (fileName.contains(term) || fileNameWithoutExtension.contains(term)) {
            termFound = true;
            break;
          }
        }
      }

      if (!termFound) {
        return false;
      }
    }

    return true;
  }

  bool _isEventWithinDateRange(String pubDateString, String startDateText, String endDateText) {
    if (pubDateString.isEmpty) return false;

    final pubDate = _parsePubDate(pubDateString);
    if (pubDate == null) return false;

    final startDate = _parseUserDate(startDateText);
    final endDate = _parseUserDate(endDateText);

    if (startDate != null && pubDate.isBefore(startDate)) {
      return false;
    }

    if (endDate != null) {
      final endOfDay = endDate.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
      if (pubDate.isAfter(endOfDay)) {
        return false;
      }
    }

    return true;
  }

  DateTime? _parseUserDate(String dateText) {
    if (dateText.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateText);
    } catch (e) {
      debugPrint('Erreur parsing date utilisateur: $e');
      return null;
    }
  }

  DateTime? _parsePubDate(String dateText) {
    if (dateText.isEmpty) return null;
    try {
      return DateTime.parse(dateText);
    } catch (e) {
      debugPrint('Erreur parsing pubDate: $e');
      return null;
    }
  }

  String _cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return '';
    return htmlContent.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'&\w+;'), ' ').trim().toLowerCase();
  }

  Widget atomEndDrawerEvent(WidgetRef ref, GlobalKey<ScaffoldState> scaffoldKey, bool isDarkMode) => AtomEndDrawer(
        scaffoldKey: scaffoldKey,
        textFilter: 'Filtrer les Actualités',
        isDarkMode: isDarkMode,
        thematicListFilter: ref.watch(thematics),
        selectedList: ref.watch(selectedList),
        onSelected: (value, index) {
          ref.read(selectedList.notifier).update(
                (state) => [
                  for (int j = 0; j < state.length; j++)
                    if (j == index) value else state[j],
                ],
              );
        },
        onApplyFilters: () => applyAllFilters(ref, searchController.text),
        startDate: startDate,
        endDate: endDate,
      );
}
