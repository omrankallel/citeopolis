import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/prod_config.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/image_app/modals/image_app.dart';
import '../../../../router/routes.dart';
import '../../../publicity/data/repositories/publicity_data_module.dart';
import '../../domain/modals/config_app.dart';
import 'background_loader_service.dart';

final preloaderProvider = ChangeNotifierProvider((ref) => PreloaderProvider());

class PreloaderProvider extends ChangeNotifier {
  final configApp = StateProvider<ConfigApp>((ref) => ConfigApp());
  int _step = 0;
  double _width = 78;
  double _height = 78;
  BorderRadiusGeometry? _borderRadius = BorderRadius.circular(50);
  Timer? _timer;

  int get step => _step;

  double get width => _width;

  double get height => _height;

  BorderRadiusGeometry? get borderRadius => _borderRadius;

  set timer(Timer value) {
    _timer = value;
  }

  ImageApp? backgroundApp;

  void changeContainerProperties(BuildContext context) {
    _step++;
    if (_step == 1) {
      _width = 300;
      _height = 300;
      _borderRadius = BorderRadius.circular(300);
    } else if (_step == 2) {
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.height;
      _borderRadius = null;
    } else {
      _timer?.cancel();
      _step = 3;
    }
    notifyListeners();
  }

  bool? statusConnection;
  bool _hasStartedBackgroundLoading = false;

  Future<void> initialisePreloader(WidgetRef ref, ConfigApp config) async {
    final isConnected = ref.watch(isConnectedProvider);
    if (config.id != 0 && isConnected != statusConnection) {
      statusConnection = isConnected;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(configApp.notifier).state = config;
        if (config.configuration?.backgroundApp != null) {
          backgroundApp = config.configuration!.backgroundApp!;
        }

        if (!_hasStartedBackgroundLoading) {
          _hasStartedBackgroundLoading = true;
          _startBackgroundLoadingAsync(ProviderScope.containerOf(ref.context));
        }

        await _navigateAfterPublicityCheck(ref);
      });
    }
  }

  void _startBackgroundLoadingAsync(ProviderContainer container) {
    () async {
      try {
        final backgroundLoader = container.read(backgroundLoaderServiceProvider);
        await backgroundLoader.loadAllAPIsFromServer(container);
      } catch (e) {
        debugPrint('Erreur lors du chargement en arrière-plan: $e');
      }
    }();
  }

  Future<void> _navigateAfterPublicityCheck(WidgetRef ref) async {
    try {
      final projectId = int.parse(ProdConfig().projectId);
      final repository = ref.read(publicityRepositoryProvider);
      final result = await repository.getPublicityFromServer(projectId);

      await result.fold(
            (error) async => goRouter.go(Paths.contentHome),
            (publicity) async {
          final String? startDateStr = publicity.displayStartDatePublicity;
          final String? endDateStr = publicity.displayEndDatePublicity;
          final int duration = int.tryParse(publicity.displayTimeSeconds ?? '') ?? 0;
          final DateTime now = DateTime.now();
          final DateTime? startDate = safeParse(startDateStr);
          final DateTime? endDate = safeParse(endDateStr);

          if (duration <= 0 || startDate == null) {
            goRouter.go(Paths.contentHome);
            return;
          }

          if (endDate == null) {
            if (!now.isBefore(startDate)) {
              goRouter.go(Paths.publicity);
            } else {
              goRouter.go(Paths.contentHome);
            }
            return;
          }

          final bool isInPeriod = !now.isBefore(startDate) && !now.isAfter(endDate);
          if (isInPeriod) {
            goRouter.go(Paths.publicity);
          } else {
            goRouter.go(Paths.contentHome);
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur navigation: $e');
      goRouter.go(Paths.contentHome);
    }
  }

  DateTime? safeParse(String? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  AlignmentGeometry positionedBloc(String position) {
    switch (position) {
      case 'top':
        return Alignment.topCenter;
      case 'medium':
        return Alignment.center;
      case 'bottom':
        return Alignment.bottomCenter;
      default:
        return Alignment.topCenter;
    }
  }

  MainAxisAlignment getMainAxisAlignment(AlignmentGeometry alignment) {
    if (alignment == Alignment.topCenter) return MainAxisAlignment.start;
    if (alignment == Alignment.bottomCenter) return MainAxisAlignment.end;
    return MainAxisAlignment.center;
  }
}