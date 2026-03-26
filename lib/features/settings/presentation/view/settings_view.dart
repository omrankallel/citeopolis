import 'package:badges/badges.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../design_system/atoms/atom_error_connexion.dart';
import '../../../../design_system/atoms/atom_text.dart';
import '../../../../router/navigation_service.dart';
import '../../../../router/routes.dart';
import '../../../../shared_widgets/custom_button.dart';
import '../../../home/presentation/view/widget/build_widget_popup_menu.dart';
import '../../../notifications/domain/modals/thematic/thematic.dart';
import '../../../notifications/presentation/view/widgets/notification_badge_widget.dart';
import '../../../notifications/presentation/viewmodel/thematic/thematic_list_view_model.dart';
import '../viewmodel/settings_view_model.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.watch(settingsProvider).initSettings(ref);
    });
  }

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, widget) {
          final settingsViewModel = ref.watch(settingsProvider);
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          return SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawerEnableOpenDragGesture: false,
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                scrolledUnderElevation: 0,
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
                actions: [
                  InkWell(
                    onTap: () {},
                    child: const bg.Badge(
                      showBadge: false,
                      ignorePointer: true,
                      child: Icon(
                        Icons.search,
                        size: 23,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  NotificationIconBadge(
                    iconData: Icons.notifications_none_sharp,
                    onTap: () => NavigationService.push(context, ref, Paths.notifications),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  InkWell(
                    onTap: () {},
                    child: const bg.Badge(
                      showBadge: false,
                      child: WidgetPopupMenu(),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              body: ref.watch(thematicListProvider).maybeMap(
                    orElse: () => const Center(child: CircularProgressIndicator()),
                    success: (thematics) {
                      thematics.data.fold((l) => Container(), (data) async {
                        settingsViewModel.initialiseThematic(ref, data);
                      });
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    15.ph,
                                    AtomText(
                                      data: 'Paramètres',
                                      style: Theme.of(context).textTheme.headlineLarge,
                                    ),
                                    50.ph,
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: AtomText(
                                        data: 'Choisir un thème',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      subtitle: AtomText(
                                        data: settingsViewModel.getValueTheme(ref),
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      trailing: const Icon(Icons.arrow_right_rounded),
                                      onTap: () => settingsViewModel.showDialogTheme(context, ref),
                                    ),
                                    10.ph,
                                    const Divider(),
                                    10.ph,
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: AtomText(
                                        data: 'Notifications',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      subtitle: AtomText(
                                        data: 'Activer les notifications et choisir les thématiques',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      trailing: Switch(
                                        value: ref.watch(settingsViewModel.switchButtonNotification),
                                        onChanged: (value) => settingsViewModel.toggleAllThematics(ref, value),
                                      ),
                                    ),
                                    15.ph,
                                    for (Thematic thematic in ref.watch(settingsViewModel.thematics)) ...[
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: AtomText(
                                          data: thematic.name ?? '',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                              ),
                                        ),
                                        trailing: Checkbox(
                                          value: thematic.checked,
                                          onChanged: (val) {
                                            if (val == null) return;
                                            settingsViewModel.toggleThematic(ref, thematic, val);
                                          },
                                        ),
                                      ),
                                      15.ph,
                                    ],
                                    10.ph,
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: CustomButtons.elevatePrimary(
                                        loading: ref.watch(settingsViewModel.loading),
                                        onPressed: () {
                                          settingsViewModel.saveThematics(ref);
                                        },
                                        title: 'Valider',
                                        borderRadius: 100,
                                        buttonColor: isDarkMode ? primaryDark : primaryLight,
                                        titleStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                                              color: isDarkMode ? onPrimaryDark : onPrimaryLight,
                                            ),
                                      ),
                                    ),
                                    10.ph,
                                    const Divider(),
                                    10.ph,
                                    AtomText(
                                      data: 'Autorisations',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    15.ph,
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: AtomText(
                                        data: 'Localisation',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      subtitle: AtomText(
                                        data: "Utiliser votre emplacement pour vous centrer sur les cartes de l'application ou vous géolocaliser",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      trailing: Switch(
                                        value: ref.watch(settingsViewModel.switchButtonLocalisation),
                                        onChanged: (value) => settingsViewModel.toggleLocation(ref, value),
                                      ),
                                    ),
                                    15.ph,
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: AtomText(
                                        data: 'Appareil photo',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      subtitle: AtomText(
                                        data: "Utiliser l'appareil photo pour l'envoi de pièce jointe dans les formulaire",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      trailing: Switch(
                                        value: ref.watch(settingsViewModel.switchButtonCamera),
                                        onChanged: (value) => settingsViewModel.toggleCamera(ref, value),
                                      ),
                                    ),
                                    15.ph,
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: AtomText(
                                        data: 'Photos',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      subtitle: AtomText(
                                        data: 'Accéder à vos photos pour les envoyer en pièce jointe dans les formulaires',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      trailing: Switch(
                                        value: ref.watch(settingsViewModel.switchButtonPicture),
                                        onChanged: (value) => settingsViewModel.togglePicture(ref, value),
                                      ),
                                    ),
                                    15.ph,
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: AtomText(
                                        data: 'Micro',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      subtitle: AtomText(
                                        data: "Utiliser le microphone pour ajouter de l'audio à vos vidéos jointes aux formulaires",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: isDarkMode ? onSurfaceDark : onSurfaceLight,
                                            ),
                                      ),
                                      trailing: Switch(
                                        value: ref.watch(settingsViewModel.switchButtonMic),
                                        onChanged: (value) => settingsViewModel.toggleMic(ref, value),
                                      ),
                                    ),
                                    100.ph,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    error: (error) => AtomErrorConnexion(
                      onTap: () {
                        ref.read(thematicViewModelStateNotifierProvider.notifier).getThematicFromLocal();
                      },
                    ),
                  ),
            ),
          );
        },
      );
}
