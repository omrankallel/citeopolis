import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_publication.dart';

final publicationsXmlProvider = ChangeNotifierProvider.autoDispose((ref) => PublicationsXmlProvider());

class PublicationsXmlProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();

  bool isInitialized = false;

  List<Publication> publications = [];
  final publicationsFiltered = StateProvider<List<Publication>>((ref) => []);

  List<TileXmlId> orderedFieldsSingleList = [];

  final thematics = StateProvider<List<String>>((ref) => []);
  final selectedList = StateProvider<List<bool>>((ref) => []);
  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  bool hasActiveSearch(String searchText) => searchText.isNotEmpty;

  Future<void> initializePublications(WidgetRef ref, TileXml tileXml, bool withScaffold) async {
    if (isInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isInitialized = true;
      if (withScaffold) {
        searchController.clear();
      } else {
        ref.read(homeProvider).searchController.clear();
      }

      publications.clear();
      ref.read(publicationsFiltered.notifier).state.clear();
      orderedFieldsSingleList.clear();

      ref.read(thematics.notifier).state.clear();
      ref.read(selectedList.notifier).state.clear();
      startDate.clear();
      endDate.clear();
    });
  }

  final configProviderFamily = FutureProvider.family.autoDispose<void, TileXml>((ref, xml) async {
    final publicationsXmlViewModel = ref.read(publicationsXmlProvider);

    try {
      final url = xml.results?.urlTile ?? '';
      final numberElement = int.parse(xml.results?.numberElement ?? '0');
      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlPublications = <XmlElement>[];
        for (final publicationNode in document.findAllElements('publication')) {
          allXmlPublications.add(publicationNode);
        }

        final config = xml.results;

        final fieldsSingleList = publicationsXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        publicationsXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isNotEmpty) {
          final List<Publication> listPublications = allXmlPublications.map((xmlElement) => Publication.fromXml(xmlElement)).toList();

          final uniqueCategories = <String>{};
          for (final publication in listPublications) {
            if (publication.category.isNotEmpty) {
              uniqueCategories.add(publication.category);
            }
          }

          final sortedCategories = uniqueCategories.toList()..sort();
          ref.read(publicationsXmlViewModel.thematics.notifier).state = sortedCategories;
          ref.read(publicationsXmlViewModel.selectedList.notifier).state = List.generate(sortedCategories.length, (index) => false);

          publicationsXmlViewModel.publications = listPublications.take(numberElement).toList();
          ref.read(publicationsXmlViewModel.publicationsFiltered.notifier).state = listPublications.take(numberElement).toList();
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

    List<Publication> result = List.from(publications);

    if (selectedThematics.isNotEmpty) {
      result = result.where((publication) => selectedThematics.contains(publication.category.toLowerCase())).toList();
    }

    if (searchText.isNotEmpty) {
      result = result.where((publication) => _matchesSearchQuery(publication, searchText)).toList();
    }
    final startDateText = startDate.text.trim();
    final endDateText = endDate.text.trim();

    if (startDateText.isNotEmpty || endDateText.isNotEmpty) {
      result = result.where((publication) => _isPublicationWithinDateRange(publication.pubDate, startDateText, endDateText)).toList();
    }

    ref.read(publicationsFiltered.notifier).state = result;
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    await applyAllFilters(ref, text);
  }

  bool _matchesSearchQuery(Publication publication, String query) {
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      publication.title,
      publication.category,
      publication.summary,
      publication.content,
      publication.imageCaption,
      publication.mainImage,
      publication.pubDate,
      publication.updateDate,
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == publication.content) {
          fieldContent = _cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == publication.mainImage && field.isNotEmpty) {
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

  bool _isPublicationWithinDateRange(String pubDateString, String startDateText, String endDateText) {
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

  Widget atomEndDrawerPublication(WidgetRef ref, GlobalKey<ScaffoldState> scaffoldKey, bool isDarkMode) => AtomEndDrawer(
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
