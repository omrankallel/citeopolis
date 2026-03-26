// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get nameApp => 'Citéopolis App';

  @override
  String get changeLanguage => 'Changer la language';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get connected => 'Connecté à Internet';

  @override
  String get msgConnexion =>
      'Pas de connexion internet\nConnecte-toi à internet et réessaie';

  @override
  String get notConnected => 'Pas de connexion Internet';

  @override
  String get showToast => 'Afficher toast';

  @override
  String get hideToast => 'Masquer toast';
}
