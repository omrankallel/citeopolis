import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../core/core.dart';
import '../../../../../../../design_system/atoms/atom_app_bar.dart';
import '../../../../../../../design_system/atoms/atom_no_result.dart';
import '../../../../../../../router/routes.dart';
import '../../../../design_system/atoms/atom_end_drawer.dart';
import '../../../../router/navigation_service.dart';
import '../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../notifications/presentation/view/widgets/notification_badge_widget.dart';

class BlankPageViewWrapper extends StatelessWidget {
  final bool withScaffold;

  const BlankPageViewWrapper({
    required this.withScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widgets) {
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          return withScaffold ? _buildWithScaffold(isDarkMode, context) : _buildWithoutScaffold(isDarkMode, context);
        },
      );

  Widget _buildWithScaffold(bool isDarkMode, BuildContext context) => SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          drawerEnableOpenDragGesture: false,
          endDrawer: AtomEndDrawer(
            textFilter: '',
            isDarkMode: isDarkMode,
            thematicListFilter: [],
            selectedList: [],
          ),
          appBar: AtomAppBarWithSearch(
            isDarkMode: isDarkMode,
            searchHint: 'Rechercher ...',
            backgroundColor: Theme.of(context).primaryColor,
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Consumer(
                builder: (context,ref,widget) => InkWell(
                    onTap: () => NavigationService.back(context, ref),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                  ),
              ),
            ),
            actions: [
              Consumer(
                builder: (context,ref,widget) => NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () => NavigationService.push(context, ref, Paths.notifications),
                  ),
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
              Expanded(child: _buildContent(isDarkMode)),
            ],
          ),
        ),
      );

  Widget _buildWithoutScaffold(bool isDarkMode, BuildContext context) => Column(
        children: [
          26.ph,
          Expanded(child: _buildContent(isDarkMode)),
        ],
      );

  Widget _buildContent(bool isDarkMode) => Center(
        child: AtomNoResult(
          text: 'Aucune donnée disponible',
          isDarkMode: isDarkMode,
          query: '',
          isBlankPage: true,
        ),
      );
}
