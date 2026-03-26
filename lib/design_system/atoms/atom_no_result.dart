import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import 'atom_text.dart';

class AtomNoResult extends StatelessWidget {
  const AtomNoResult({
    required this.text,
    required this.query,
    required this.isDarkMode,
    this.isBlankPage = false,
    super.key,
  });

  final String text;
  final String query;
  final bool isDarkMode;
  final bool isBlankPage;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isBlankPage) ...[
              Icon(
                Icons.search_off,
                size: 64,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
              16.ph,
            ],
            AtomText(
              data: 'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (!isBlankPage) ...[
              8.ph,
              AtomText(
                data: 'Aucun $text ne correspond à "$query"',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              8.ph,
              AtomText(
                data: "Essayez avec d'autres mots-clés",
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      );
}
