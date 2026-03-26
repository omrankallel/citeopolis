import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../memory/shared_preferences_service.dart';

final localizationsService = ChangeNotifierProvider<LocalizationsService>((ref) => LocalizationsService()..init());

class LocalizationsService extends ChangeNotifier {
  Locale _appLocal = const Locale('en');

  Locale get appLocal => _appLocal;

  Future<void> init() async {
    final String? languageCode = await SharedPreferencesService().get('language_code');

    _appLocal = languageCode != null ? Locale(languageCode) : const Locale('en');

    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_appLocal.languageCode == locale.languageCode) return;

    _appLocal = locale;

    await SharedPreferencesService().add('language_code', locale.languageCode);

    notifyListeners();
  }
}
