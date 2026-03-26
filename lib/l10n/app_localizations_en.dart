// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nameApp => 'Citéopolis App';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get connected => 'Internet connected';

  @override
  String get msgConnexion =>
      'No internet connection\nConnect to the internet and try again';

  @override
  String get notConnected => 'No internet connection';

  @override
  String get showToast => 'Show toast';

  @override
  String get hideToast => 'Hide toast';
}
