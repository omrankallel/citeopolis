import 'package:dartz/dartz.dart' as st;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prod_config.dart';
import '../../../../../core/memory/data_state.dart';
import '../../../../../core/network/connectivity_provider.dart';
import '../../../../../core/state/state.dart';
import '../../domain/modals/publicity.dart';
import '../../domain/repositories/publicity_domain_module.dart';
import '../../domain/usecases/publicity_use_case.dart';

final publicityListProviderLoader = Provider<DataState<Publicity>>((ref) {
  final publicityAppState = ref.watch(publicityViewModelStateNotifierProvider);
  return publicityAppState;
});

final publicityListProvider = Provider<State<st.Either<String, Publicity>>>((ref) {
  final publicityAppState = ref.watch(publicityViewModelStateNotifierProvider);
  return publicityAppState.state.when(
    init: () => const State.init(),
    success: (publicity) => State.success(publicity),
    loading: () => const State.loading(),
    error: (exception) => State.error(exception),
  );
});

final publicityViewModelStateNotifierProvider = StateNotifierProvider<PublicityViewModel, DataState<Publicity>>(
  (ref) => PublicityViewModel(
    ref.watch(publicityUseCaseProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

class PublicityViewModel extends StateNotifier<DataState<Publicity>> {
  final PublicityUseCase _publicityUseCase;
  final ConnectivityService _connectivityService;

  PublicityViewModel(this._publicityUseCase, this._connectivityService) : super(const DataState<Publicity>(state: State.init())) {
    debugPrint('🎯 ÉTAPE 4: Initialisation PublicityViewModel');
    getPublicityProjectFromLocal();
  }

  /// ÉTAPE 4: Charge UNIQUEMENT depuis le local storage (données déjà chargées par l'ÉTAPE 2)
  Future<void> getPublicityProjectFromLocal() async {
    if (!mounted) return;

    try {
      debugPrint('📺 ÉTAPE 4: Chargement Publicity depuis local storage...');

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: await _connectivityService.hasConnection(),
      );

      final String idProject = ProdConfig().projectId;
      final publicity = await _publicityUseCase.getPublicityFromLocal(int.parse(idProject));

      if (!mounted) return;

      publicity.fold(
        (error) {
          debugPrint('❌ ÉTAPE 4: Données locales Publicity non disponibles: $error');
          state = state.copyWith(
            state: State.error(Exception('Données locales non disponibles: $error')),
            isFromCache: true,
          );
        },
        (r) {
          debugPrint('✅ ÉTAPE 4: Publicity chargé depuis local storage');
          state = state.copyWith(
            state: State.success(publicity),
            isFromCache: true,
          );
        },
      );
    } on Exception catch (e) {
      if (!mounted) return;
      debugPrint('❌ ÉTAPE 4: Exception Publicity: $e');
      state = state.copyWith(
        state: State.error(e),
        isFromCache: true,
      );
    }
  }

  /// ÉTAPE 5: Méthode pour forcer le refresh depuis le serveur
  Future<void> refreshFromServer() async {
    if (!mounted) return;

    try {
      debugPrint('🔄 ÉTAPE 5: Force refresh Publicity depuis serveur...');

      final hasConnection = await _connectivityService.hasConnection();

      if (!hasConnection) {
        debugPrint('📴 ÉTAPE 5: Pas de connexion - recharge depuis local');
        // Si pas de connexion, juste recharger depuis le local
        await getPublicityProjectFromLocal();
        return;
      }

      state = state.copyWith(
        state: const State.loading(),
        hasConnection: hasConnection,
      );

      final String idProject = ProdConfig().projectId;
      final publicity = await _publicityUseCase.getPublicityFromServer(int.parse(idProject));

      if (!mounted) return;

      publicity.fold(
        (error) {
          debugPrint('❌ ÉTAPE 5: Erreur refresh serveur - fallback vers local');
          // En cas d'erreur serveur, fallback vers le local
          getPublicityProjectFromLocal();
        },
        (r) {
          debugPrint('✅ ÉTAPE 5: Publicity refresh depuis serveur et sauvé en local');
          state = state.copyWith(
            state: State.success(publicity),
            isFromCache: false,
          );
        },
      );
    } on Exception catch (e) {
      if (!mounted) return;
      debugPrint('❌ ÉTAPE 5: Exception refresh - fallback vers local: $e');
      // En cas d'erreur, fallback vers le local
      await getPublicityProjectFromLocal();
    }
  }

  /// Alias pour l'ancienne méthode (compatibilité)
  Future<void> getPublicityProject() async {
    debugPrint('🔄 ÉTAPE 4: Appel de getPublicityProject - redirection vers local');
    await getPublicityProjectFromLocal();
  }
}
