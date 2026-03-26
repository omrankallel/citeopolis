import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/service.dart';
import '../../../../core/core.dart';
import '../../../../core/memory/local_storage_list_service.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/injector.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../design_system/atoms/atom_text.dart';
import '../../../../router/routes.dart';
import '../../../notifications/domain/modals/thematic/thematic.dart';

final settingsProvider = ChangeNotifierProvider.autoDispose((ref) => SettingsProvider());

class SettingsProvider extends ChangeNotifier {
  final loading = StateProvider<bool>((ref) => false);

  final switchButtonNotification = StateProvider<bool>((ref) => false);
  final switchButtonLocalisation = StateProvider<bool>((ref) => false);
  final switchButtonCamera = StateProvider<bool>((ref) => false);
  final switchButtonPicture = StateProvider<bool>((ref) => false);
  final switchButtonMic = StateProvider<bool>((ref) => false);

  final groupValueTheme = StateProvider<int>((ref) {
    final mode = ref.watch(themeProvider).themeMode;
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 3;
    }
  });

  String getValueTheme(WidgetRef ref) {
    final int value = ref.watch(groupValueTheme);
    switch (value) {
      case 1:
        return 'Clair';
      case 2:
        return 'Sombre';
      case 3:
        return "Paramètre par défaut de l'appareil";
      default:
        return "Paramètre par défaut de l'appareil";
    }
  }

  bool? statusConnectionThematic;
  final thematics = StateProvider<List<Thematic>>((ref) => []);
  final selectedList = StateProvider<List<bool>>((ref) => []);

  void initialiseThematic(WidgetRef ref, List<Thematic> listThematics) {
    final isConnected = ref.watch(isConnectedProvider);
    if (statusConnectionThematic != isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final savedThematics = getIt<LocalStorageListService<Thematic>>().get('thematic') ?? [];

        final loadedThematics = listThematics.map((item) {
          final savedItem = savedThematics.firstWhere(
            (saved) => saved.termId == item.termId,
            orElse: () => item,
          );
          return item.copyWith(checked: savedItem.checked);
        }).toList();

        ref.read(selectedList.notifier).state.clear();
        ref.read(thematics.notifier).state.clear();
        ref.read(thematics.notifier).state = loadedThematics;
        ref.read(selectedList.notifier).state = loadedThematics.map((e) => e.checked).toList();

        final allChecked = loadedThematics.isNotEmpty && loadedThematics.every((t) => t.checked);
        ref.read(switchButtonNotification.notifier).state = allChecked;

        statusConnectionThematic = isConnected;
      });
    }
  }

  void toggleAllThematics(WidgetRef ref, bool value) {
    ref.read(switchButtonNotification.notifier).state = value;
    ref.read(thematics.notifier).update(
      (state) {
        final updatedList = [
          for (Thematic thematic in state) thematic.copyWith(checked: value),
        ];
        return updatedList;
      },
    );
  }

  void toggleThematic(WidgetRef ref, Thematic thematic, bool value) {
    ref.read(thematics.notifier).update((state) {
      final updatedList = state.map((t) => t.termId == thematic.termId ? t.copyWith(checked: value) : t).toList();
      return updatedList;
    });

    ref.read(switchButtonNotification.notifier).state = ref.read(thematics).every((thematic) => thematic.checked);
  }

  Future<void> saveThematics(WidgetRef ref) async {
    ref.read(loading.notifier).state = true;

    await getIt<LocalStorageListService<Thematic>>().save('thematic', ref.read(thematics));

    final String token = await NotificationService.getFCMToken() ?? '';

    final data = {
      'os': Platform.operatingSystem,
      'token': token,
      'thematiques': ref.read(thematics).map((e) => e.termId).toList(),
      'id_project': ProdConfig().projectId,
    };

    final response = await ApiRequest().request(RequestMethod.post, Services.deviceRegistration, data: data, getStatus: true);
    ref.read(loading.notifier).state = false;

    if (response.statusCode == 200) {
      if (ref.context.mounted) {
        _showHandlerPopup(ref.context, ref, 'Votre demande a été envoyée. !', false);
      }
    } else {
      if (ref.context.mounted) {
        _showHandlerPopup(ref.context, ref, 'Une erreur est survenue. Veuillez réessayer plus tard.', true);
      }
    }
  }

  void _showHandlerPopup(BuildContext context, WidgetRef ref, String message, bool isError) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: MediaQuery.of(context).size.width * .85,
          padding: EdgeInsets.zero,
          color: isDarkMode ? Colors.black : Colors.white,
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      10.ph,
                      SvgPicture.asset(
                        Assets.assetsImageReportSent,
                        colorFilter: ColorFilter.mode(
                          isError
                              ? Colors.red
                              : isDarkMode
                                  ? primaryDark
                                  : primaryLight,
                          BlendMode.srcIn,
                        ),
                        height: 120,
                      ),
                      30.ph,
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      10.ph,
                    ],
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showDialogTheme(BuildContext context, WidgetRef ref) async {
    final groupValue = StateProvider<int>((ref) => ref.read(groupValueTheme));
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
        ),
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: AtomText(
              data: 'Annuler',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  ),
            ),
          ),
          16.pw,
          InkWell(
            onTap: () {
              switch (ref.read(groupValue)) {
                case 1:
                  ref.read(groupValueTheme.notifier).state = 1;
                  ref.watch(themeProvider).setThemeMode(ThemeMode.light);
                  break;
                case 2:
                  ref.read(groupValueTheme.notifier).state = 2;
                  ref.watch(themeProvider).setThemeMode(ThemeMode.dark);
                  break;
                case 3:
                  ref.read(groupValueTheme.notifier).state = 3;
                  ref.watch(themeProvider).setThemeMode(ThemeMode.system);
                  break;
              }
              Navigator.pop(context);
            },
            child: AtomText(
              data: 'Ok',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ref.watch(themeProvider).isDarkMode ? primaryDark : primaryLight,
                  ),
            ),
          ),
        ],
        content: Consumer(
          builder: (context, ref, widget) => SizedBox(
            width: Helpers.getResponsiveWidth(context) * .6,
            height: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtomText(
                  data: 'Sélectionner un thème',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                20.ph,
                ListTile(
                  onTap: () {
                    ref.read(groupValue.notifier).state = 1;
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: RadioGroup<int>(
                      groupValue: ref.watch(groupValue),
                      onChanged: (value) {
                        ref.read(groupValue.notifier).state = 1;
                      },
                      child: const Radio<int>(value: 1),
                    ),
                  ),
                  title: AtomText(
                    data: 'Clair',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    ref.read(groupValue.notifier).state = 2;
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: RadioGroup<int>(
                      groupValue: ref.watch(groupValue),
                      onChanged: (value) {
                        ref.read(groupValue.notifier).state = 2;
                      },
                      child: const Radio<int>(value: 2),
                    ),
                  ),
                  title: AtomText(
                    data: 'Sombre',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    ref.read(groupValue.notifier).state = 3;
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: RadioGroup<int>(
                      groupValue: ref.watch(groupValue),
                      onChanged: (value) {
                        ref.read(groupValue.notifier).state = 3;
                      },
                      child: const Radio<int>(value: 3),
                    ),
                  ),
                  title: AtomText(
                    data: "Paramètre par défaut de l'appareil",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> toggleLocation(WidgetRef ref, bool value) async {
    if (value) {
      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission().then((permissionValue) {
          ref.read(switchButtonLocalisation.notifier).state = permissionValue == LocationPermission.always || permissionValue == LocationPermission.whileInUse;
        });
      } else {
        goRouter.goNamed(Paths.contentHome);
        await openAppSettings();
      }
    } else {
      goRouter.goNamed(Paths.contentHome);
      await openAppSettings();
    }
  }

  Future<void> initSettings(WidgetRef ref) async {
    final LocationPermission permission = await Geolocator.checkPermission();
    ref.read(switchButtonLocalisation.notifier).state = permission == LocationPermission.always || permission == LocationPermission.whileInUse;

    final cameraStatus = await Permission.camera.status;
    ref.read(switchButtonCamera.notifier).state = cameraStatus.isGranted;

    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;
    ref.read(switchButtonPicture.notifier).state = photosStatus.isGranted || storageStatus.isGranted;

    final micStatus = await Permission.microphone.status;
    ref.read(switchButtonMic.notifier).state = micStatus.isGranted;
  }

  Future<void> toggleCamera(WidgetRef ref, bool value) async {
    if (value) {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        ref.read(switchButtonCamera.notifier).state = true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else {
      await openAppSettings();
    }
  }

  Future<void> togglePicture(WidgetRef ref, bool value) async {
    if (value) {
      final photosStatus = await Permission.photos.request();
      final storageStatus = await Permission.storage.request();
      if (photosStatus.isGranted || storageStatus.isGranted) {
        ref.read(switchButtonPicture.notifier).state = true;
      } else if (photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else {
      await openAppSettings();
    }
  }

  Future<void> toggleMic(WidgetRef ref, bool value) async {
    if (value) {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        ref.read(switchButtonMic.notifier).state = true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else {
      await openAppSettings();
    }
  }
}
