import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../home/domain/modals/content_home/build_page.dart';
import '../../../home/domain/modals/content_home/carrousel.dart';
import '../../../home/domain/modals/content_home/event.dart';
import '../../../home/domain/modals/content_home/news.dart';
import '../../../home/domain/modals/content_home/publication.dart';
import '../../../home/domain/modals/content_home/quick_access.dart';
import '../../../home/domain/modals/content_home/repeater.dart';
import '../../../home/domain/modals/content_home/row.dart' as row;
import '../../../home/domain/modals/content_home/section.dart';
import '../../../home/presentation/viewmodel/home_view_model.dart';

final contentHomeProvider = ChangeNotifierProvider((ref) => ContentHomeProvider());

class ContentHomeProvider extends ChangeNotifier {
  final currentIndexCarousel = StateProvider<Map<String, int>>((ref) => {});
  final controllerCarouselList = StateProvider<Map<String, CarouselSliderController>>((ref) => {});

  void changeCurrentIndexCarousel(int selectedIndex, int index, WidgetRef ref) {
    final String id = ref.read(buildPageFiltered).sections?[selectedIndex].id ?? '';
    ref.read(currentIndexCarousel.notifier).update(
          (state) => {
            ...state,
            id: index,
          },
        );
  }


  final isSlid = StateProvider<List<bool>>((ref) => List.generate(3, (_) => false));

  final buildPageFiltered = StateProvider<BuildPage>((ref) => BuildPage());
  final buildPageOriginal = StateProvider<BuildPage>((ref) => BuildPage());

  bool? statusConnection;

  void initialiseContentHome(WidgetRef ref, BuildPage buildPage) {
    final isConnected = ref.watch(isConnectedProvider);
    if (statusConnection != isConnected) {
      statusConnection = isConnected;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(buildPageOriginal.notifier).state = buildPage.copyWith();
        ref.read(buildPageFiltered.notifier).state = buildPage.copyWith();
        final Map<String, int> initialIndexes = {};
        final Map<String, CarouselSliderController> initialCarousel = {};
        final List<Section> sections = buildPage.sections ?? [];
        for (int i = 0; i < sections.length; i++) {
          if (sections[i].type == 'carousel' && sections[i].carrousel?.carrouselRepeater != null) {
            initialIndexes[sections[i].id ?? ''] = 0;
            initialCarousel[sections[i].id ?? ''] = CarouselSliderController();
          }
        }
        ref.read(currentIndexCarousel.notifier).state = initialIndexes;
        ref.read(controllerCarouselList.notifier).state = initialCarousel;
      });
    }
  }

  void onSearchTextChanged(WidgetRef ref, String query) {
    ref.read(ref.watch(homeProvider).searchText.notifier).state = query;
    _performSearch(ref, query);
  }

  void _performSearch(WidgetRef ref, String query) {
    if (query.isEmpty) {
      ref.read(buildPageFiltered.notifier).state = ref.watch(buildPageOriginal);
    } else {
      final originalBuildPage = ref.watch(buildPageOriginal);
      final searchResults = _searchInBuildPage(originalBuildPage, query.toLowerCase());
      ref.read(buildPageFiltered.notifier).state = searchResults;
    }
  }

  BuildPage _searchInBuildPage(BuildPage? buildPage, String query) {
    if (buildPage == null || buildPage.sections == null || buildPage.sections!.isEmpty) {
      return BuildPage(sections: []);
    }

    final filteredSections = buildPage.sections!.where((section) => _matchesSearchQueryInSection(section, query)).map((section) => _filterSection(section, query)).toList();

    return BuildPage(sections: filteredSections);
  }

  bool _matchesSearchQueryInSection(Section section, String query) {
    if (section.quickAccess != null && section.quickAccess!.rows != null) {
      final matchesQuickAccess = section.quickAccess!.rows!.any((row) => _matchesSearchQueryInRow(row, query));
      if (matchesQuickAccess) return true;
    }

    if (section.carrousel != null && section.carrousel!.carrouselRepeater != null) {
      final matchesCarousel = section.carrousel!.carrouselRepeater!.any((repeater) => _matchesSearchQueryInRepeater(repeater, query));
      if (matchesCarousel) return true;
    }

    if (section.news != null) {
      if (_matchesSearchQueryInNews(section.news!, query)) return true;
      if (section.news!.newsRepeater != null) {
        final matchesNewsRepeaters = section.news!.newsRepeater!.any((repeater) => _matchesSearchQueryInRepeater(repeater, query));
        if (matchesNewsRepeaters) return true;
      }
    }

    if (section.event != null) {
      if (_matchesSearchQueryInEvent(section.event!, query)) return true;
      if (section.event!.eventRepeater != null) {
        final matchesEventRepeaters = section.event!.eventRepeater!.any((repeater) => _matchesSearchQueryInRepeater(repeater, query));
        if (matchesEventRepeaters) return true;
      }
    }

    if (section.publication != null) {
      if (_matchesSearchQueryInPublication(section.publication!, query)) return true;
      if (section.publication!.publicationRepeater != null) {
        final matchesPublicationRepeaters = section.publication!.publicationRepeater!.any((repeater) => _matchesSearchQueryInRepeater(repeater, query));
        if (matchesPublicationRepeaters) return true;
      }
    }

    return false;
  }

  Section _filterSection(Section section, String query) => Section(
        type: section.type,
        order: section.order,
        hidden: section.hidden,
        quickAccess: _filterQuickAccess(section.quickAccess, query),
        carrousel: _filterCarousel(section.carrousel, query),
        news: _filterNews(section.news, query),
        event: _filterEvent(section.event, query),
        publication: _filterPublication(section.publication, query),
      );

  QuickAccess? _filterQuickAccess(QuickAccess? quickAccess, String query) {
    if (quickAccess == null || quickAccess.rows == null) return null;

    final filteredRows = (quickAccess.rows ?? []).where((row) => _matchesSearchQueryInRow(row, query)).toList();

    if (filteredRows.isEmpty) return null;
    return quickAccess.copyWith(rows: filteredRows);
  }

  Carrousel? _filterCarousel(Carrousel? carrousel, String query) {
    if (carrousel == null || carrousel.carrouselRepeater == null) return null;

    final filteredRepeaters = (carrousel.carrouselRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

    if (filteredRepeaters.isEmpty) return null;
    return carrousel.copyWith(carrouselRepeater: filteredRepeaters);
  }

  News? _filterNews(News? news, String query) {
    if (news == null) return null;

    final newsMatches = _matchesSearchQueryInNews(news, query);
    final filteredRepeaters = (news.newsRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

    if (!newsMatches && filteredRepeaters.isEmpty) return null;

    return news.copyWith(
      newsRepeater: filteredRepeaters.isNotEmpty ? filteredRepeaters : null,
    );
  }

  Event? _filterEvent(Event? event, String query) {
    if (event == null) return null;

    final eventMatches = _matchesSearchQueryInEvent(event, query);
    final filteredRepeaters = (event.eventRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

    if (!eventMatches && filteredRepeaters.isEmpty) return null;

    return event.copyWith(
      eventRepeater: filteredRepeaters.isNotEmpty ? filteredRepeaters : null,
    );
  }

  Publication? _filterPublication(Publication? publication, String query) {
    if (publication == null) return null;

    final publicationMatches = _matchesSearchQueryInPublication(publication, query);
    final filteredRepeaters = (publication.publicationRepeater ?? []).where((repeater) => _matchesSearchQueryInRepeater(repeater, query)).toList();

    if (!publicationMatches && filteredRepeaters.isEmpty) return null;

    return publication.copyWith(
      publicationRepeater: filteredRepeaters.isNotEmpty ? filteredRepeaters : null,
    );
  }

  bool _matchesSearchQueryInRow(row.Row row, String query) => (row.title ?? '').toLowerCase().contains(query) || (row.secondaryTitle ?? '').toLowerCase().contains(query) || (row.pictogramName ?? '').toLowerCase().contains(query) || (row.urlLink ?? '').toLowerCase().contains(query) || (row.tile ?? '').toLowerCase().contains(query);

  bool _matchesSearchQueryInEvent(Event event, String query) => (event.titleEvent ?? '').toLowerCase().contains(query) || (event.urlLink ?? '').toLowerCase().contains(query) || (event.tile ?? '').toLowerCase().contains(query);

  bool _matchesSearchQueryInPublication(Publication publication, String query) => (publication.titlePublication ?? '').toLowerCase().contains(query) || (publication.urlLink ?? '').toLowerCase().contains(query) || (publication.tile ?? '').toLowerCase().contains(query);

  bool _matchesSearchQueryInNews(News news, String query) => (news.titleNews ?? '').toLowerCase().contains(query) || (news.urlLink ?? '').toLowerCase().contains(query) || (news.tile ?? '').toLowerCase().contains(query);

  bool _matchesSearchQueryInRepeater(Repeater repeater, String query) => (repeater.repTitle ?? '').toLowerCase().contains(query) || (repeater.repThematic ?? '').toLowerCase().contains(query) || (repeater.repStartDate ?? '').toLowerCase().contains(query) || (repeater.repEndDate ?? '').toLowerCase().contains(query) || (repeater.repUrl ?? '').toLowerCase().contains(query) || (repeater.repTile ?? '').toLowerCase().contains(query);

  void clearSearch(WidgetRef ref) {
    ref.read(ref.watch(homeProvider).searchText.notifier).state = '';
    ref.read(buildPageFiltered.notifier).state = ref.read(buildPageOriginal);
  }
}
