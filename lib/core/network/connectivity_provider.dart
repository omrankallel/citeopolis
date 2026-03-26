import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

import '../extensions/extensions.dart' show BuildContextX;

final connectivityProvider = ChangeNotifierProvider((ref) => ConnectivityProvider());

final isConnectedProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.isConnected;
});

class ConnectivityService {
  final ConnectivityProvider _connectivityProvider;

  ConnectivityService(this._connectivityProvider);

  Future<bool> hasConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  bool get isCurrentlyConnected => _connectivityProvider.isConnected;
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService(ref.watch(connectivityProvider)));

class ConnectivityProvider with ChangeNotifier {
  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none];
  bool _isConnected = false;
  ToastFuture? toastFuture;
  BuildContext? _context;
  bool _initialized = false;
  bool _overlayReady = false;

  ConnectivityProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  bool get isConnected => _isConnected;

  List<ConnectivityResult> get connectivityResult => _connectivityResult;

  void setContext(BuildContext context) {
    _context = context;

    Future.delayed(const Duration(milliseconds: 500), () {
      _overlayReady = true;
    });

    if (!_initialized) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      _connectivityResult = await Connectivity().checkConnectivity();
      _isConnected = !_connectivityResult.contains(ConnectivityResult.none);
      _initialized = true;
      notifyListeners();

      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
        final wasConnected = _isConnected;
        _connectivityResult = result;
        _isConnected = !result.contains(ConnectivityResult.none);

        if (wasConnected != _isConnected && _context != null && _overlayReady) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_context != null && _overlayReady) {
              showToast(_isConnected);
            }
          });
        }

        notifyListeners();
      });
    } catch (e) {
      debugPrint("Erreur d'initialisation de la connectivité: $e");
      _isConnected = false;
      _initialized = true;
      notifyListeners();
    }
  }

  void showToast(bool isConnected) {
    if (_context == null || !_overlayReady) return;

    try {
      final String msg = isConnected ? _context!.localizations?.connected ?? 'Connexion rétablie' : _context!.localizations?.msgConnexion ?? 'Pas de connexion internet';

      final Widget toastWithButton = Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

      if (toastFuture != null) {
        try {
          toastFuture!.dismiss(showAnim: true);
        } catch (e) {
          debugPrint('Erreur lors de la fermeture du toast précédent: $e');
        }
        toastFuture = null;
      }

      try {
        toastFuture = showToastWidget(
          duration: isConnected ? const Duration(seconds: 3) : const Duration(seconds: 10),
          toastWithButton,
          animationCurve: Curves.easeInOut,
          position: ToastPosition.bottom,
        );
      } catch (e) {
        debugPrint("Erreur lors de l'affichage du toast: $e");
        toastFuture = null;
      }
    } catch (e) {
      debugPrint('Erreur dans showToast: $e');
    }
  }

  Future<void> checkConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final wasConnected = _isConnected;
      _connectivityResult = result;
      _isConnected = !result.contains(ConnectivityResult.none);

      if (wasConnected != _isConnected && _context != null && _overlayReady) {
        showToast(_isConnected);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la connexion: $e');
    }
  }

  @override
  void dispose() {
    toastFuture?.dismiss();
    super.dispose();
  }
}
