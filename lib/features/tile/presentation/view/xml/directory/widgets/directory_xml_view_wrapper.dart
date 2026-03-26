import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../../../../domain/modals/xml/xml_directory.dart';
import '../../../../viewmodel/xml/directory/directories_xml_view_model.dart';

class DirectoryXmlViewWrapper extends StatelessWidget {
  final bool withScaffold;
  final TileXml tileXml;

  const DirectoryXmlViewWrapper({
    required this.tileXml,
    required this.withScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final directoriesXmlViewModel = ref.watch(directoriesXmlProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          directoriesXmlViewModel.initializeDirectories(ref, tileXml, withScaffold);
          return withScaffold ? _buildWithScaffold(ref, isDarkMode, context) : _buildWithoutScaffold(ref, isDarkMode, context);
        },
      );

  Widget _buildWithScaffold(WidgetRef ref, bool isDarkMode, BuildContext context) {
    final directoriesXmlViewModel = ref.watch(directoriesXmlProvider);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: directoriesXmlViewModel.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        drawerEnableOpenDragGesture: false,
        endDrawer: directoriesXmlViewModel.atomEndDrawerDirectory(ref, directoriesXmlViewModel.scaffoldKey, isDarkMode),
        appBar: AtomAppBarWithSearch(
          searchController: directoriesXmlViewModel.searchController,
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
          onSearchChanged: (text) => directoriesXmlViewModel.onSearchTextChanged(ref, text),
          onSearchCleared: () => directoriesXmlViewModel.onSearchTextChanged(ref, ''),
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
            _buildHeader(ref, directoriesXmlViewModel.scaffoldKey, isDarkMode, context),
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
              text: 'Annuaires',
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
    final directoriesXmlViewModel = ref.watch(directoriesXmlProvider);
    final filteredDirectories = ref.watch(directoriesXmlViewModel.directoriesFiltered);
    final orderedFields = directoriesXmlViewModel.orderedFieldsSingleList;

    final searchText = withScaffold ? directoriesXmlViewModel.searchController.text : ref.watch(homeProvider).searchController.text;

    return ref.watch(directoriesXmlViewModel.configProviderFamily(tileXml)).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFCA542B)),
          ),
          data: (_) => orderedFields.isEmpty
              ? const SizedBox()
              : filteredDirectories.isEmpty && directoriesXmlViewModel.hasActiveSearch(searchText)
                  ? AtomNoResult(
                      isDarkMode: isDarkMode,
                      query: searchText,
                      text: 'Directory',
                    )
                  : _buildDirectoriesList(ref, filteredDirectories, searchText, isDarkMode),
          error: (error, _) => Center(
            child: Text(
              'Erreur : $error',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
  }

  Widget _buildDirectoriesList(WidgetRef ref, List<Directory> filteredDirectories, String searchText, bool isDarkMode) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                itemCount: filteredDirectories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final directory = filteredDirectories[index];
                  return _buildDirectoryCard(context, ref, directory, searchText, isDarkMode);
                },
                separatorBuilder: (context, index) => 32.ph,
              ),
              50.ph,
            ],
          ),
        ),
      );

  Widget _buildDirectoryCard(BuildContext context, WidgetRef ref, Directory directory, String searchText, bool isDarkMode) {
    final directoriesXmlViewModel = ref.watch(directoriesXmlProvider);

    return InkWell(
      onTap: () {
        NavigationService.push(
          context,
          ref,
          Paths.detailDirectoryXml,
          extra: {
            'tileXml': tileXml,
            'directoryXml': directory,
            'allDirectories': directoriesXmlViewModel.directories,
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
          children: _buildDirectoryFields(context, ref, directory, isDarkMode, searchText),
        ),
      ),
    );
  }

  List<Widget> _buildDirectoryFields(BuildContext context, WidgetRef ref, Directory directory, bool isDarkMode, String searchText) {
    final directoriesXmlViewModel = ref.watch(directoriesXmlProvider);
    final orderedFields = directoriesXmlViewModel.orderedFieldsSingleList;
    final widgets = <Widget>[];

    for (final field in orderedFields) {
      final fieldTag = (field.balise ?? '').toLowerCase();

      switch (fieldTag) {
        case 'title':
          if (directory.title.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: directory.title,
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
          if (directory.mainImage.isNotEmpty) {
            widgets.addAll([
              Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AtomUploadImage(
                    base64ImageData: directory.mainImage,
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
          if (directory.category.isNotEmpty) {
            widgets.addAll([
              AtomHighlightedText(
                text: directory.category,
                searchQuery: searchText,
                style: Theme.of(context).textTheme.titleMedium!,
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
}
