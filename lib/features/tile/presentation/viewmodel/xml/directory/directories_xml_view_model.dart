import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../../home/presentation/viewmodel/home_view_model.dart';
import '../../../../domain/modals/tile_xml.dart';
import '../../../../domain/modals/xml/xml_directory.dart';

final directoriesXmlProvider = ChangeNotifierProvider.autoDispose((ref) => DirectoriesXmlProvider());

class DirectoriesXmlProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();

  bool isInitialized = false;

  List<Directory> directories = [];
  final directoriesFiltered = StateProvider<List<Directory>>((ref) => []);

  List<TileXmlId> orderedFieldsSingleList = [];

  final thematics = StateProvider<List<String>>((ref) => []);
  final selectedList = StateProvider<List<bool>>((ref) => []);

  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  bool hasActiveSearch(String searchText) => searchText.isNotEmpty;

  Future<void> initializeDirectories(WidgetRef ref, TileXml tileXml, bool withScaffold) async {
    if (isInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isInitialized = true;
      if (withScaffold) {
        searchController.clear();
      } else {
        ref.read(homeProvider).searchController.clear();
      }

      directories.clear();
      ref.read(directoriesFiltered.notifier).state.clear();
      orderedFieldsSingleList.clear();

      ref.read(thematics.notifier).state.clear();
      ref.read(selectedList.notifier).state.clear();
      startDate.clear();
      endDate.clear();
    });
  }

  final configProviderFamily = FutureProvider.family.autoDispose<void, TileXml>((ref, xml) async {
    final directoriesXmlViewModel = ref.read(directoriesXmlProvider);

    try {
      final url = xml.results?.urlTile ?? '';
      final numberElement = int.parse(xml.results?.numberElement ?? '0');
      final response = await ApiRequest().request(RequestMethod.get, Services.getFlux, queryParameters: {'url': url}, getStatus: true);
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.data);

        final allXmlDirectories = <XmlElement>[];
        for (final directoryNode in document.findAllElements('entry')) {
          allXmlDirectories.add(directoryNode);
        }

        final config = xml.results;

        final fieldsSingleList = directoriesXmlViewModel.getVisibleOrderItems(config?.idsSingle);

        directoriesXmlViewModel.orderedFieldsSingleList = fieldsSingleList;

        if (fieldsSingleList.isNotEmpty) {
          final List<Directory> listDirectories = allXmlDirectories.map((xmlElement) => Directory.fromXml(xmlElement)).toList();

          final uniqueCategories = <String>{};
          for (final directory in listDirectories) {
            if (directory.category.isNotEmpty) {
              uniqueCategories.add(directory.category);
            }
          }

          final sortedCategories = uniqueCategories.toList()..sort();
          ref.read(directoriesXmlViewModel.thematics.notifier).state = sortedCategories;
          ref.read(directoriesXmlViewModel.selectedList.notifier).state = List.generate(sortedCategories.length, (index) => false);

          directoriesXmlViewModel.directories = listDirectories.take(numberElement).toList();
          ref.read(directoriesXmlViewModel.directoriesFiltered.notifier).state = listDirectories.take(numberElement).toList();
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

    List<Directory> result = List.from(directories);

    if (selectedThematics.isNotEmpty) {
      result = result.where((directory) => selectedThematics.contains(directory.category.toLowerCase())).toList();
    }

    if (searchText.isNotEmpty) {
      result = result.where((directory) => _matchesSearchQuery(directory, searchText)).toList();
    }

    final startDateText = startDate.text.trim();
    final endDateText = endDate.text.trim();

    if (startDateText.isNotEmpty || endDateText.isNotEmpty) {
      result = result.where((article) => _isDirectoryWithinDateRange(article.pubDate, startDateText, endDateText)).toList();
    }

    ref.read(directoriesFiltered.notifier).state = result;
  }

  Future<void> onSearchTextChanged(WidgetRef ref, String text) async {
    await applyAllFilters(ref, text);
  }

  bool _matchesSearchQuery(Directory directory, String query) {
    final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();

    final searchableFields = [
      directory.title,
      directory.category,
      directory.summary,
      directory.content,
      directory.imageCaption,
      directory.mainImage,
      directory.pubDate.toString(),
      directory.updateDate.toString(),
      directory.additionalInformation,
      directory.website,
      directory.phone1,
      directory.phone2,
      directory.email,
      directory.contact.firstName,
      directory.contact.lastName,
      directory.contact.phone,
      directory.contact.email,
      directory.location.title,
      directory.location.address,
      directory.location.postalCode,
      directory.location.city,
      directory.location.latitude.toString(),
      directory.location.longitude.toString(),
      directory.facebook,
      directory.twitter,
      directory.instagram,
      directory.linkedin,
      directory.youtube,
      ...directory.schedule.map(
        (s) => '${s.dayName} ${s.datetime}',
      ),
    ].where((field) => field.isNotEmpty).toList();

    for (final term in searchTerms) {
      bool termFound = false;

      for (final field in searchableFields) {
        String fieldContent = field;

        if (field == directory.content) {
          fieldContent = _cleanHtmlContent(field);
        } else {
          fieldContent = field.toLowerCase();
        }

        if (fieldContent.contains(term)) {
          termFound = true;
          break;
        }

        if (field == directory.mainImage && field.isNotEmpty) {
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

  bool _isDirectoryWithinDateRange(String pubDateString, String startDateText, String endDateText) {
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

  Widget atomEndDrawerDirectory(WidgetRef ref, GlobalKey<ScaffoldState> scaffoldKey, bool isDarkMode) => AtomEndDrawer(
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
