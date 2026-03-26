import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../../router/navigation_service.dart';
import '../../../../../router/routes.dart';
import '../../viewmodel/home_view_model.dart';

class WidgetPopupMenu extends StatelessWidget {
  const WidgetPopupMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          final homeViewModel = ref.watch(homeProvider);
          return PopupMenuButton<int>(
            constraints: const BoxConstraints.expand(width: 200, height: 220),
            color: ref.watch(themeProvider).isDarkMode ? surfaceContainerDark : surfaceContainerLight,
            offset: const Offset(130, 40),
            onOpened: () => ref.read(homeViewModel.isPopupOpen.notifier).state = true,
            onCanceled: () => ref.read(homeViewModel.isPopupOpen.notifier).state = false,
            onSelected: (index) async {
              ref.read(homeViewModel.isPopupOpen.notifier).state = false;
              if (index == 0) {
                await homeViewModel.showDialogLanguage(context, ref);
              } else if (index == 1) {
                NavigationService.go(context, ref, Paths.settings);
              } else if (index == 2) {
                goRouter.go(
                  Paths.urlTileWithScaffold,
                  extra: {
                    'url': homeViewModel.configApp.configuration?.urlLegalPage ?? '',
                    'isTile': false,
                  },
                );
              } else if (index == 3) {
                NavigationService.go(
                  context,
                  ref,
                  Paths.urlTileWithScaffold,
                  extra: {
                    'url': homeViewModel.configApp.configuration?.urlProtectionPage ?? '',
                    'isTile': false,
                  },
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: const EdgeInsets.only(left: 10),
                value: 0,
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded),
                    const SizedBox(width: 10),
                    Text(
                      'Langue (FR)',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                padding: const EdgeInsets.only(left: 10),
                value: 1,
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: 10),
                    Text(
                      'Paramètre',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                padding: const EdgeInsets.only(left: 10),
                value: 2,
                child: Text(
                  'Mentions légales',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              PopupMenuItem(
                padding: const EdgeInsets.only(left: 10),
                value: 3,
                child: Text(
                  'Protection des données',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: ref.watch(homeViewModel.isPopupOpen)
                    ? ref.watch(themeProvider).isDarkMode
                        ? primaryDark
                        : primaryLight
                    : null,
              ),
              child: Icon(
                Icons.more_vert,
                color: ref.watch(homeViewModel.isPopupOpen)
                    ? ref.watch(themeProvider).isDarkMode
                        ? onPrimaryDark
                        : onPrimaryLight
                    : null,
                size: 23,
              ),
            ),
          );
        },
      );
}
