import 'package:flutter/material.dart';

import 'atom_highlighted_text.dart';

class AtomTextIcon extends StatelessWidget {
  const AtomTextIcon({
    required this.data,
    this.spacing = 16,
    this.style,
    this.iconData,
    this.sizeIcon,
    this.onTap,
    this.searchQuery='',
    this.isDarkMode=true,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final double spacing;
  final IconData? iconData;
  final double? sizeIcon;
  final GestureTapCallback? onTap;
  final String searchQuery;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Flexible(
              child: AtomHighlightedText(
                text: data,
                searchQuery: searchQuery,
                style: style ?? Theme.of(context).textTheme.headlineLarge!,
                isDarkMode: isDarkMode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: spacing),
            Icon(
              iconData ?? Icons.arrow_forward,
              size: sizeIcon ?? 24,
            ),
          ],
        ),
      );
}
