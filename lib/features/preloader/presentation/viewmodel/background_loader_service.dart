import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/prod_config.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/services/feed/domain/repositories/feed_domain_module.dart';
import '../../../../core/services/feed/domain/usecases/feed_use_case.dart';
import '../../../../core/services/term/domain/repositories/term_domain_module.dart';
import '../../../../core/services/term/domain/usecases/term_use_case.dart';
import '../../../home/domain/repositories/content_home/content_home_domain_module.dart';
import '../../../home/domain/repositories/menu/menu_domain_module.dart';
import '../../../home/domain/repositories/tab_bar/tab_bar_domain_module.dart';
import '../../../home/domain/usecases/content_home/content_home_use_case.dart';
import '../../../home/domain/usecases/menu/menu_use_case.dart';
import '../../../home/domain/usecases/tab_bar/tab_bar_use_case.dart';
import '../../../notifications/data/repositories/notification/notification_data_module.dart';
import '../../../notifications/domain/repositories/notification/notification_domain_module.dart';
import '../../../notifications/domain/repositories/thematic/thematic_domain_module.dart';
import '../../../notifications/domain/usecases/notification/notification_use_case.dart';
import '../../../notifications/domain/usecases/thematic/thematic_use_case.dart';
import '../../../notifications/presentation/viewmodel/notifications_view_model.dart';
import '../../../publicity/domain/repositories/publicity_domain_module.dart';
import '../../../publicity/domain/usecases/publicity_use_case.dart';
import '../../../tile/domain/repositories/tile_domain_module.dart';
import '../../../tile/domain/usecases/tile_use_case.dart';

const _kTtlKey = 'bg_load_ts_';
const _kCacheTTL = Duration(minutes: 30);

final backgroundLoaderServiceProvider = Provider<BackgroundLoaderService>(
  (ref) => BackgroundLoaderService(
    ref.watch(publicityUseCaseProvider),
    ref.watch(contentHomeUseCaseProvider),
    ref.watch(menuUseCaseProvider),
    ref.watch(tabBarUseCaseProvider),
    ref.watch(notificationUseCaseProvider),
    ref.watch(thematicUseCaseProvider),
    ref.watch(tileUseCaseProvider),
    ref.watch(feedUseCaseProvider),
    ref.watch(termUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

final backgroundLoadingStateProvider = StateProvider<BackgroundLoadingState>((ref) => BackgroundLoadingState.idle);

enum BackgroundLoadingState {
  idle,
  loading,
  completed,
  error,
}

class BackgroundLoaderService {
  final PublicityUseCase _publicityUseCase;
  final ContentHomeUseCase _contentHomeUseCase;
  final MenuUseCase _menuUseCase;
  final TabBarUseCase _tabBarUseCase;
  final NotificationUseCase _notificationUseCase;
  final ThematicUseCase _thematicUseCase;
  final TileUseCase _tileUseCase;
  final FeedUseCase _feedUseCase;
  final TermUseCase _termUseCase;
  final ConnectivityService _connectivityService;

  BackgroundLoaderService(
    this._publicityUseCase,
    this._contentHomeUseCase,
    this._menuUseCase,
    this._tabBarUseCase,
    this._notificationUseCase,
    this._thematicUseCase,
    this._tileUseCase,
    this._feedUseCase,
    this._termUseCase,
    this._connectivityService,
  );

  Future<void> loadAllAPIsFromServer(ProviderContainer container, {bool forceRefresh = false}) async {
    try {
      _safeUpdateState(container, BackgroundLoadingState.loading);

      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        await _refreshNotificationCountFromLocal(container);
        _safeUpdateState(container, BackgroundLoadingState.error);
        return;
      }

      final projectId = int.parse(ProdConfig().projectId);

      if (!forceRefresh && await _isCacheStillValid(projectId)) {
        debugPrint('Cache encore valide — rechargement ignoré');
        await _refreshNotificationCountFromLocal(container);
        _safeUpdateState(container, BackgroundLoadingState.completed);
        return;
      }

      final criticalResults = await Future.wait([
        _loadContentHomeFromServer(projectId),
        _loadMenusFromServer(projectId),
        _loadTabBarsFromServer(projectId),
        _loadPublicityFromServer(projectId),
      ]);
      debugPrint('Groupe 1 terminé: ${criticalResults.where((r) => r).length}/4 succès');

      final notifSuccess = await _loadNotificationFromServer(projectId);
      final secondaryResults = await Future.wait([
        _loadThematicFromServer(projectId),
        _loadTileFromServer(projectId),
        _loadFeedFromServer(projectId),
        _loadTermFromServer(projectId),
      ]);
      debugPrint('Groupe 2 terminé: ${secondaryResults.where((r) => r).length}/4 succès');

      if (notifSuccess) {
        await _refreshNotificationCountFromLocal(container);
      }

      final anySuccess = [
        ...criticalResults,
        secondaryResults,
        [notifSuccess],
      ].expand((r) => r is List ? r : [r]).any((r) => r == true);

      if (anySuccess) {
        await _saveCacheTimestamp(projectId);
        _safeUpdateState(container, BackgroundLoadingState.completed);
      } else {
        _safeUpdateState(container, BackgroundLoadingState.error);
      }
    } catch (e) {
      debugPrint('Erreur BackgroundLoader: $e');
      _safeUpdateState(container, BackgroundLoadingState.error);
    }
  }

  Future<void> _refreshNotificationCountFromLocal(ProviderContainer container) async {
    try {
      final projectId = int.parse(ProdConfig().projectId);
      final repository = container.read(notificationRepositoryProvider);
      final result = await repository.getUnreadNotificationsCount(projectId);
      final count = result.fold((error) => 0, (count) => count);
      _safeUpdateCount(container, count);
      debugPrint('Compteur notifications mis à jour: $count');
    } catch (e) {
      debugPrint('Erreur mise à jour compteur notifications: $e');
    }
  }

  void _safeUpdateCount(ProviderContainer container, int count) {
    try {
      container.read(unreadCountStateProvider.notifier).state = count;
    } catch (_) {}
  }

  void _safeUpdateState(ProviderContainer container, BackgroundLoadingState state) {
    try {
      container.read(backgroundLoadingStateProvider.notifier).state = state;
    } catch (_) {}
  }

  Future<bool> _isCacheStillValid(int projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoad = prefs.getInt('$_kTtlKey$projectId');
      if (lastLoad == null) return false;
      return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastLoad)) < _kCacheTTL;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveCacheTimestamp(int projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_kTtlKey$projectId', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  Future<void> invalidateCache(int projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_kTtlKey$projectId');
    } catch (_) {}
  }

  Future<void> refreshAllAPIsFromServer(ProviderContainer container) async {
    await loadAllAPIsFromServer(container, forceRefresh: true);
  }

  Future<bool> _loadPublicityFromServer(int projectId) async {
    try {
      final result = await _publicityUseCase.getPublicityFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadContentHomeFromServer(int projectId) async {
    try {
      final result = await _contentHomeUseCase.getPageHomeFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadMenusFromServer(int projectId) async {
    try {
      final result = await _menuUseCase.getMenuProjectFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadTabBarsFromServer(int projectId) async {
    try {
      final result = await _tabBarUseCase.getTabBarProjectFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadNotificationFromServer(int projectId) async {
    try {
      final result = await _notificationUseCase.getNotificationFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadThematicFromServer(int projectId) async {
    try {
      final result = await _thematicUseCase.getThematicFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadTileFromServer(int projectId) async {
    try {
      final result = await _tileUseCase.getTileProjectFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadFeedFromServer(int projectId) async {
    try {
      final result = await _feedUseCase.getFeedProjectFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadTermFromServer(int projectId) async {
    try {
      final result = await _termUseCase.getTermProjectFromServer(projectId);
      return result.fold((e) => false, (d) => true);
    } catch (_) {
      return false;
    }
  }
}
