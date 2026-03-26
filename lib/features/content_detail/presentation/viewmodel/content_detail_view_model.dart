import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../home/domain/modals/content_home/build_page.dart';
import '../../../home/domain/modals/content_home/event.dart';
import '../../../home/domain/modals/content_home/flux_xml_rss_item.dart';
import '../../../home/domain/modals/content_home/news.dart';
import '../../../home/domain/modals/content_home/publication.dart';
import '../../../home/domain/modals/content_home/repeater.dart';
import '../../../home/domain/modals/content_home/section.dart';

final contentDetailProvider = ChangeNotifierProvider((ref) => ContentDetailProvider());

class ContentDetailProvider extends ChangeNotifier {
  int selectedIndex = -1;

  final searchController = TextEditingController();
  final searchText = StateProvider<String>((ref) => '');
  final hasSearchResults = StateProvider<bool>((ref) => false);

  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  final selectedList = StateProvider<List<bool>>((ref) => []);
  final thematics = StateProvider<List<String>>((ref) => []);

  bool? statusConnectionPageHome;
  final filteredSection = StateProvider<Section>((ref) => Section());

  Section _originalSection = Section();
  bool _hasActiveFilters = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  Future<void> initialise(WidgetRef ref, int selectedIndex) async {
    this.selectedIndex = selectedIndex;
    startDate.clear();
    endDate.clear();
    statusConnectionPageHome = null;
    ref.read(selectedList.notifier).state.clear();
    ref.read(thematics.notifier).state.clear();
    ref.read(filteredSection.notifier).state = Section();
    ref.read(hasSearchResults.notifier).state = false;
    _originalSection = Section();
    _hasActiveFilters = false;
  }

  void initialiseContentHome(WidgetRef ref, BuildPage buildPage) {
    final isConnected = ref.watch(isConnectedProvider);
    if (statusConnectionPageHome != isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        statusConnectionPageHome = isConnected;
        _originalSection = buildPage.sections![selectedIndex].copyWith();
        ref.read(filteredSection.notifier).state = buildPage.sections![selectedIndex].copyWith();

        _initializeThematics(ref);
      });
    }
  }

  void _initializeThematics(WidgetRef ref) {
    ref.read(thematics.notifier).state.clear();

    final type = _originalSection.type ?? '';
    Set<String> thematicSet = {};

    switch (type) {
      case 'news':
        thematicSet = _extractNewsThematics();
        break;
      case 'event':
        thematicSet = _extractEventThematics();
        break;
      case 'publication':
        thematicSet = _extractPublicationThematics();
        break;
    }

    ref.read(thematics.notifier).state.addAll(thematicSet);
    ref.read(selectedList.notifier).state = List.generate(thematicSet.length, (index) => false);
  }

  Set<String> _extractNewsThematics() {
    final displayMode = _originalSection.news?.displayMode ?? '';
    if (displayMode == '1') {
      return _originalSection.news?.newsRepeater?.map((e) => e.repThematic ?? '').where((thematic) => thematic.isNotEmpty).toSet() ?? {};
    } else if (displayMode == '2') {
      return _originalSection.news?.fluxXmlRSSChannel?.items.map((e) => e.category ?? '').where((category) => category.isNotEmpty).toSet() ?? {};
    }
    return {};
  }

  Set<String> _extractEventThematics() {
    final displayMode = _originalSection.event?.displayMode ?? '';
    if (displayMode == '1') {
      return _originalSection.event?.eventRepeater?.map((e) => e.repThematic ?? '').where((thematic) => thematic.isNotEmpty).toSet() ?? {};
    } else if (displayMode == '2') {
      return _originalSection.event?.fluxXmlRSSChannel?.items.map((e) => e.category ?? '').where((category) => category.isNotEmpty).toSet() ?? {};
    }
    return {};
  }

  Set<String> _extractPublicationThematics() {
    final displayMode = _originalSection.publication?.displayMode ?? '';
    if (displayMode == '1') {
      return _originalSection.publication?.publicationRepeater?.map((e) => e.repThematic ?? '').where((thematic) => thematic.isNotEmpty).toSet() ?? {};
    } else if (displayMode == '2') {
      return _originalSection.publication?.fluxXmlRSSChannel?.items.map((e) => e.category ?? '').where((category) => category.isNotEmpty).toSet() ?? {};
    }
    return {};
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    final cleanDateStr = dateStr.trim();

    try {
      final parsed = DateTime.parse(cleanDateStr);
      return parsed;
    } catch (e) {
      debugPrint('⚠️ Échec parsing ISO 8601: $e');

      final formats = [
        DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz', 'en_US'),
        DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US'),
        DateFormat('EEEE, dd MMM yyyy HH:mm:ss zzz', 'en_US'),
        DateFormat('dd MMM yyyy HH:mm:ss zzz', 'en_US'),
        DateFormat('dd MMM yyyy HH:mm:ss Z', 'en_US'),
        DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US'),
        DateFormat('dd MMM yyyy HH:mm:ss', 'en_US'),
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"),
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('yyyy-MM-dd'),
      ];

      for (var format in formats) {
        try {
          final parsed = format.parse(cleanDateStr);
          return parsed;
        } catch (_) {
          continue;
        }
      }

      return null;
    }
  }

  void applyFilters(WidgetRef ref) {
    final filterConfig = _getFilterConfiguration(ref);

    _hasActiveFilters = filterConfig.hasFilters;

    if (!_hasActiveFilters) {
      ref.read(filteredSection.notifier).state = _originalSection.copyWith();
      return;
    }

    final filteredPage = _originalSection.copyWith();
    _applyFilterByType(filteredPage, filterConfig);
    ref.read(filteredSection.notifier).state = filteredPage;
  }

  _FilterConfiguration _getFilterConfiguration(WidgetRef ref) {
    final selectedStates = ref.read(selectedList.notifier).state;
    final allThematics = ref.read(thematics.notifier).state;

    final selectedThematicNames = <String>[];
    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedThematicNames.add(allThematics[i].toLowerCase());
      }
    }

    DateTime? filterStartDate;
    DateTime? filterEndDate;

    if (startDate.text.trim().isNotEmpty) {
      try {
        filterStartDate = DateFormat('dd/MM/yyyy').parse(startDate.text.trim());
      } catch (e) {
        debugPrint('Erreur parsing date début: $e');
      }
    }

    if (endDate.text.trim().isNotEmpty) {
      try {
        filterEndDate = DateFormat('dd/MM/yyyy').parse(endDate.text.trim());
        filterEndDate = DateTime(filterEndDate.year, filterEndDate.month, filterEndDate.day, 23, 59, 59);
      } catch (e) {
        debugPrint('Erreur parsing date fin: $e');
      }
    }

    return _FilterConfiguration(
      thematics: selectedThematicNames,
      startDate: filterStartDate,
      endDate: filterEndDate,
    );
  }

  void _applyFilterByType(Section filteredPage, _FilterConfiguration config) {
    switch (filteredPage.type ?? '') {
      case 'news':
        _filterNews(filteredPage, config.thematics);
        break;
      case 'event':
        _filterEvents(filteredPage, config.thematics, config.startDate, config.endDate);
        break;
      case 'publication':
        _filterPublications(filteredPage, config.thematics);
        break;
    }
  }

  void _filterNews(Section filteredPage, List<String> selectedThematicNames) {
    if (filteredPage.news == null) return;

    final displayMode = filteredPage.news!.displayMode ?? '';

    if (displayMode == '1' && filteredPage.news!.newsRepeater != null) {
      final filtered = filteredPage.news!.newsRepeater!.where((item) => _matchesThematic(item.repThematic, selectedThematicNames)).toList();
      filteredPage.news = filteredPage.news!.copyWith(newsRepeater: filtered);
    } else if (displayMode == '2' && filteredPage.news!.fluxXmlRSSChannel?.items != null) {
      final filtered = filteredPage.news!.fluxXmlRSSChannel!.items.where((item) => _matchesThematic(item.category, selectedThematicNames)).toList();
      final updatedChannel = filteredPage.news!.fluxXmlRSSChannel!.copyWith(items: filtered);
      filteredPage.news = filteredPage.news!.copyWith(fluxXmlRSSChannel: updatedChannel);
    }
  }

  void _filterEvents(Section filteredPage, List<String> selectedThematicNames, DateTime? filterStartDate, DateTime? filterEndDate) {
    if (filteredPage.event == null) return;

    final displayMode = filteredPage.event!.displayMode ?? '';

    if (displayMode == '1' && filteredPage.event!.eventRepeater != null) {
      final filtered = filteredPage.event!.eventRepeater!.where((item) => _matchesThematic(item.repThematic, selectedThematicNames) && _matchesEventDateRange(item.repStartDate, item.repEndDate, filterStartDate, filterEndDate)).toList();
      filteredPage.event = filteredPage.event!.copyWith(eventRepeater: filtered);
    } else if (displayMode == '2' && filteredPage.event!.fluxXmlRSSChannel?.items != null) {
      final filtered = filteredPage.event!.fluxXmlRSSChannel!.items.where((item) => _matchesThematic(item.category, selectedThematicNames) && _matchesRSSDateRange(item.pubDate, item.eventStartDate, item.eventEndDate, filterStartDate, filterEndDate)).toList();
      final updatedChannel = filteredPage.event!.fluxXmlRSSChannel!.copyWith(items: filtered);
      filteredPage.event = filteredPage.event!.copyWith(fluxXmlRSSChannel: updatedChannel);
    }
  }

  void _filterPublications(Section filteredPage, List<String> selectedThematicNames) {
    if (filteredPage.publication == null) return;

    final displayMode = filteredPage.publication!.displayMode ?? '';

    if (displayMode == '1' && filteredPage.publication!.publicationRepeater != null) {
      final filtered = filteredPage.publication!.publicationRepeater!.where((item) => _matchesThematic(item.repThematic, selectedThematicNames)).toList();
      filteredPage.publication = filteredPage.publication!.copyWith(publicationRepeater: filtered);
    } else if (displayMode == '2' && filteredPage.publication!.fluxXmlRSSChannel?.items != null) {
      final filtered = filteredPage.publication!.fluxXmlRSSChannel!.items.where((item) => _matchesThematic(item.category, selectedThematicNames)).toList();
      final updatedChannel = filteredPage.publication!.fluxXmlRSSChannel!.copyWith(items: filtered);
      filteredPage.publication = filteredPage.publication!.copyWith(fluxXmlRSSChannel: updatedChannel);
    }
  }

  bool _matchesThematic(String? thematic, List<String> selectedThematics) {
    if (selectedThematics.isEmpty) return true;
    if (thematic == null || thematic.isEmpty) return false;
    return selectedThematics.contains(thematic.toLowerCase());
  }

  bool _matchesEventDateRange(String? startDateStr, String? endDateStr, DateTime? filterStartDate, DateTime? filterEndDate) {
    if (filterStartDate == null && filterEndDate == null) {
      return true;
    }

    final DateTime? eventStartDate = _parseDate(startDateStr);
    final DateTime? eventEndDate = _parseDate(endDateStr);

    if (eventStartDate == null && eventEndDate == null) {
      return false;
    }

    if (eventStartDate != null && eventEndDate != null) {
      final bool startsBeforeFilterEnd = filterEndDate == null || eventStartDate.isBefore(filterEndDate) || eventStartDate.isAtSameMomentAs(filterEndDate);
      final bool endsAfterFilterStart = filterStartDate == null || eventEndDate.isAfter(filterStartDate) || eventEndDate.isAtSameMomentAs(filterStartDate);

      final bool matches = startsBeforeFilterEnd && endsAfterFilterStart;

      return matches;
    }

    final DateTime eventDate = eventStartDate ?? eventEndDate!;

    bool matches = true;

    if (filterStartDate != null && eventDate.isBefore(filterStartDate)) {
      matches = false;
    }

    if (filterEndDate != null && eventDate.isAfter(filterEndDate)) {
      matches = false;
    }

    return matches;
  }

  bool _matchesRSSDateRange(String? pubDateStr, String? eventStartDateStr, String? eventEndDateStr, DateTime? filterStartDate, DateTime? filterEndDate) {
    if (filterStartDate == null && filterEndDate == null) {
      return true;
    }

    final DateTime? eventStartDate = _parseDate(eventStartDateStr);
    final DateTime? eventEndDate = _parseDate(eventEndDateStr);

    if (eventStartDate != null && eventEndDate != null) {
      final bool startsBeforeFilterEnd = filterEndDate == null || eventStartDate.isBefore(filterEndDate) || eventStartDate.isAtSameMomentAs(filterEndDate);
      final bool endsAfterFilterStart = filterStartDate == null || eventEndDate.isAfter(filterStartDate) || eventEndDate.isAtSameMomentAs(filterStartDate);

      final bool matches = startsBeforeFilterEnd && endsAfterFilterStart;

      return matches;
    }

    final DateTime? rssDate = eventStartDate ?? eventEndDate ?? _parseDate(pubDateStr);

    if (rssDate == null) {
      return false;
    }

    bool matches = true;

    if (filterStartDate != null && rssDate.isBefore(filterStartDate)) {
      matches = false;
    }

    if (filterEndDate != null && rssDate.isAfter(filterEndDate)) {
      matches = false;
    }

    return matches;
  }

  void clearFilters(WidgetRef ref) {
    final thematics = ref.read(selectedList.notifier).state;
    ref.read(selectedList.notifier).state = List.generate(thematics.length, (index) => false);

    startDate.clear();
    endDate.clear();

    ref.read(filteredSection.notifier).state = _originalSection.copyWith();
    _hasActiveFilters = false;
  }

  bool get hasActiveFilters => _hasActiveFilters;

  String textTitle(WidgetRef ref) {
    switch (_originalSection.type ?? '') {
      case 'news':
        return _originalSection.news?.titleNews ?? 'Actualités';
      case 'event':
        return _originalSection.event?.titleEvent ?? 'Événements';
      case 'publication':
        return _originalSection.publication?.titlePublication ?? 'Publications';
      default:
        return '';
    }
  }

  void onSearchTextChanged(WidgetRef ref, String query) {
    ref.read(searchText.notifier).state = query;
    _performSearch(ref, query);
  }

  void _performSearch(WidgetRef ref, String query) {
    if (query.isEmpty) {
      if (_hasActiveFilters) {
        applyFilters(ref);
      } else {
        ref.read(filteredSection.notifier).state = _originalSection;
      }
      ref.read(hasSearchResults.notifier).state = false;
    } else {
      final searchResults = _searchInSection(_originalSection, query.toLowerCase());
      final finalResults = _applyFiltersToSearchResults(ref, searchResults);
      final hasResults = _hasResultsInSection(finalResults);
      ref.read(hasSearchResults.notifier).state = hasResults;
      ref.read(filteredSection.notifier).state = finalResults;
    }
  }

  Section _applyFiltersToSearchResults(WidgetRef ref, Section searchResults) {
    if (!_hasActiveFilters) return searchResults;

    final filterConfig = _getFilterConfiguration(ref);
    final filteredResults = searchResults.copyWith();
    _applyFilterByType(filteredResults, filterConfig);

    return filteredResults;
  }

  bool _hasResultsInSection(Section section) {
    switch (section.type ?? '') {
      case 'news':
        final displayMode = section.news?.displayMode ?? '';
        if (displayMode == '1') {
          return section.news?.newsRepeater?.isNotEmpty ?? false;
        } else if (displayMode == '2') {
          return section.news?.fluxXmlRSSChannel?.items.isNotEmpty ?? false;
        }
        break;

      case 'event':
        final displayMode = section.event?.displayMode ?? '';
        if (displayMode == '1') {
          return section.event?.eventRepeater?.isNotEmpty ?? false;
        } else if (displayMode == '2') {
          return section.event?.fluxXmlRSSChannel?.items.isNotEmpty ?? false;
        }
        break;

      case 'publication':
        final displayMode = section.publication?.displayMode ?? '';
        if (displayMode == '1') {
          return section.publication?.publicationRepeater?.isNotEmpty ?? false;
        } else if (displayMode == '2') {
          return section.publication?.fluxXmlRSSChannel?.items.isNotEmpty ?? false;
        }
        break;
    }
    return false;
  }

  Section _searchInSection(Section? section, String query) {
    if (section == null) return Section();

    switch (section.type ?? '') {
      case 'event':
        return _searchInEvent(section, query);
      case 'publication':
        return _searchInPublication(section, query);
      case 'news':
        return _searchInNews(section, query);
      default:
        return Section();
    }
  }

  Section _searchInEvent(Section section, String query) {
    Event? filteredEvent;
    final displayMode = section.event?.displayMode ?? '';

    if (displayMode == '1' && section.event != null) {
      final eventMatches = _matchesSearchQueryInEvent(section.event!, query);
      final filteredRepeaters = (section.event!.eventRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

      if (eventMatches || filteredRepeaters.isNotEmpty) {
        filteredEvent = section.event!.copyWith(eventRepeater: filteredRepeaters.isNotEmpty ? filteredRepeaters : section.event!.eventRepeater);
      }
    } else if (displayMode == '2' && section.event != null) {
      final eventMatches = _matchesSearchQueryInEvent(section.event!, query);
      final filteredRSSItems = (section.event!.fluxXmlRSSChannel?.items ?? []).where((rssItem) => _matchesSearchQueryInRSSItem(rssItem, query)).toList();

      if (eventMatches || filteredRSSItems.isNotEmpty) {
        final updatedChannel = section.event!.fluxXmlRSSChannel?.copyWith(
          items: filteredRSSItems.isNotEmpty ? filteredRSSItems : section.event!.fluxXmlRSSChannel?.items ?? [],
        );
        filteredEvent = section.event!.copyWith(fluxXmlRSSChannel: updatedChannel);
      }
    }

    return Section(event: filteredEvent);
  }

  Section _searchInPublication(Section section, String query) {
    Publication? filteredPublication;
    final displayMode = section.publication?.displayMode ?? '';

    if (displayMode == '1' && section.publication != null) {
      final publicationMatches = _matchesSearchQueryInPublication(section.publication!, query);
      final filteredRepeaters = (section.publication!.publicationRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

      if (publicationMatches || filteredRepeaters.isNotEmpty) {
        filteredPublication = section.publication!.copyWith(publicationRepeater: filteredRepeaters.isNotEmpty ? filteredRepeaters : section.publication!.publicationRepeater);
      }
    } else if (displayMode == '2' && section.publication != null) {
      final publicationMatches = _matchesSearchQueryInPublication(section.publication!, query);
      final filteredRSSItems = (section.publication!.fluxXmlRSSChannel?.items ?? []).where((rssItem) => _matchesSearchQueryInRSSItem(rssItem, query)).toList();

      if (publicationMatches || filteredRSSItems.isNotEmpty) {
        final updatedChannel = section.publication!.fluxXmlRSSChannel?.copyWith(
          items: filteredRSSItems.isNotEmpty ? filteredRSSItems : section.publication!.fluxXmlRSSChannel?.items ?? [],
        );
        filteredPublication = section.publication!.copyWith(fluxXmlRSSChannel: updatedChannel);
      }
    }

    return Section(publication: filteredPublication);
  }

  Section _searchInNews(Section section, String query) {
    News? filteredNews;
    final displayMode = section.news?.displayMode ?? '';

    if (displayMode == '1' && section.news != null) {
      final newsMatches = _matchesSearchQueryInNews(section.news!, query);
      final filteredRepeaters = (section.news!.newsRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

      if (newsMatches || filteredRepeaters.isNotEmpty) {
        filteredNews = section.news!.copyWith(newsRepeater: filteredRepeaters.isNotEmpty ? filteredRepeaters : section.news!.newsRepeater);
      }
    } else if (displayMode == '2' && section.news != null) {
      final newsMatches = _matchesSearchQueryInNews(section.news!, query);
      final filteredRSSItems = (section.news!.fluxXmlRSSChannel?.items ?? []).where((rssItem) => _matchesSearchQueryInRSSItem(rssItem, query)).toList();

      if (newsMatches || filteredRSSItems.isNotEmpty) {
        final updatedChannel = section.news!.fluxXmlRSSChannel?.copyWith(
          items: filteredRSSItems.isNotEmpty ? filteredRSSItems : section.news!.fluxXmlRSSChannel?.items ?? [],
        );
        filteredNews = section.news!.copyWith(fluxXmlRSSChannel: updatedChannel);
      }
    }

    return Section(news: filteredNews);
  }

  bool _matchesSearchQueryInRSSItem(FluxXmlRSSItem rssItem, String query) => _containsQuery(rssItem.title, query) || _containsQuery(rssItem.category, query) || _containsQuery(rssItem.description, query) || _containsQuery(rssItem.link, query) || _containsQuery(rssItem.pubDate, query);

  bool _matchesSearchQueryInEvent(Event event, String query) => _containsQuery(event.titleEvent, query) || _containsQuery(event.urlLink, query) || _containsQuery(event.tile, query) || (event.eventRepeater?.any((repeater) => _matchesSearchQueryInRepeater(repeater, query)) ?? false);

  bool _matchesSearchQueryInPublication(Publication publication, String query) => _containsQuery(publication.titlePublication, query) || _containsQuery(publication.urlLink, query) || _containsQuery(publication.tile, query) || (publication.publicationRepeater?.any((repeater) => _matchesSearchQueryInRepeater(repeater, query)) ?? false);

  bool _matchesSearchQueryInNews(News news, String query) => _containsQuery(news.titleNews, query) || _containsQuery(news.urlLink, query) || _containsQuery(news.tile, query) || (news.newsRepeater?.any((repeater) => _matchesSearchQueryInRepeater(repeater, query)) ?? false);

  bool _matchesSearchQueryInRepeater(Repeater repeater, String query) => _containsQuery(repeater.repTitle, query) || _containsQuery(repeater.repThematic, query) || _containsQuery(repeater.repStartDate, query) || _containsQuery(repeater.repEndDate, query) || _containsQuery(repeater.repUrl, query) || _containsQuery(repeater.repTile, query);

  bool _containsQuery(String? text, String query) => (text ?? '').toLowerCase().contains(query);

  void clearSearch(WidgetRef ref) {
    ref.read(searchText.notifier).state = '';
    searchController.clear();

    if (_hasActiveFilters) {
      applyFilters(ref);
    } else {
      ref.read(filteredSection.notifier).state = _originalSection;
    }
    ref.read(hasSearchResults.notifier).state = false;
  }

  @override
  void dispose() {
    searchController.dispose();
    startDate.dispose();
    endDate.dispose();
    super.dispose();
  }
}

class _FilterConfiguration {
  final List<String> thematics;
  final DateTime? startDate;
  final DateTime? endDate;

  _FilterConfiguration({
    required this.thematics,
    this.startDate,
    this.endDate,
  });

  bool get hasFilters => thematics.isNotEmpty || startDate != null || endDate != null;
}
