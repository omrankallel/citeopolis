import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../router/routes.dart';

class AtomHighlightedText extends StatelessWidget {
  final String text;
  final String searchQuery;
  final TextStyle style;
  final bool isDarkMode;
  final bool isHtml;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Color backgroundColor;
  final bool underline;

  const AtomHighlightedText({
    required this.text,
    required this.searchQuery,
    required this.style,
    this.isDarkMode = false,
    this.isHtml = false,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.backgroundColor = Colors.yellow,
    this.underline = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => isHtml ? _buildHighlightedHtmlContent(text, searchQuery, isDarkMode) : _buildHighlightedText(text, searchQuery, style, isDarkMode);

  Widget _buildHighlightedText(String text, String searchQuery, TextStyle style, bool isDarkMode) => RichText(
        text: _buildHighlightedTextSpan(text, searchQuery, style, isDarkMode),
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
        textAlign: textAlign ?? TextAlign.start,
      );

  TextSpan _buildHighlightedTextSpan(String text, String searchQuery, TextStyle style, bool isDarkMode) {
    if (searchQuery.isEmpty || text.isEmpty) {
      return TextSpan(
        text: text,
        style: style.copyWith(
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
          decorationColor: style.color,
          height: underline ? 1.8 : null,
        ),
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final List<String> searchTerms = searchQuery.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();

    int lastMatchEnd = 0;
    final List<MapEntry<int, int>> allMatches = [];

    for (final term in searchTerms) {
      int startIndex = 0;
      while (startIndex < lowerText.length) {
        final index = lowerText.indexOf(term, startIndex);
        if (index == -1) break;
        allMatches.add(MapEntry(index, index + term.length));
        startIndex = index + 1;
      }
    }

    allMatches.sort((a, b) => a.key.compareTo(b.key));

    final List<MapEntry<int, int>> mergedMatches = [];
    for (final match in allMatches) {
      if (mergedMatches.isEmpty || match.key > mergedMatches.last.value) {
        mergedMatches.add(match);
      } else {
        final lastMatch = mergedMatches.removeLast();
        mergedMatches.add(MapEntry(lastMatch.key, math.max(lastMatch.value, match.value)));
      }
    }

    for (final match in mergedMatches) {
      if (lastMatchEnd < match.key) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.key), style: style));
      }

      spans.add(
        TextSpan(
          text: text.substring(match.key, match.value),
          style: style.copyWith(
            backgroundColor: backgroundColor.withValues(alpha: .7),
            color: isDarkMode ? Colors.black : Colors.black,
            fontWeight: FontWeight.bold,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: style.color,
            height: underline ? 1.8 : null,
          ),
        ),
      );

      lastMatchEnd = match.value;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(children: spans);
  }

  Widget _buildHighlightedHtmlContent(String htmlContent, String searchQuery, bool isDarkMode) {
    final highlightedHtml = _injectHighlightInHtml(htmlContent, searchQuery);

    return HtmlWidget(
      highlightedHtml,
      textStyle: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      onTapUrl: (url) async {
        goRouter.go(Paths.urlTileWithScaffold, extra: url);
        return true;
      },
    );
  }

  String _injectHighlightInHtml(String htmlContent, String searchQuery) {
    if (searchQuery.isEmpty) return htmlContent;

    final List<String> searchTerms = searchQuery.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();
    String modifiedHtml = htmlContent;

    for (final term in searchTerms) {
      modifiedHtml = _highlightTextInHtml(modifiedHtml, term);
    }

    return modifiedHtml;
  }

  String _highlightTextInHtml(String html, String searchTerm) {
    final StringBuffer result = StringBuffer();
    int lastIndex = 0;
    bool insideTag = false;

    for (int i = 0; i < html.length; i++) {
      final char = html[i];

      if (char == '<') {
        insideTag = true;
      } else if (char == '>') {
        insideTag = false;
      }

      if (!insideTag && i + searchTerm.length <= html.length) {
        final substring = html.substring(i, i + searchTerm.length);
        if (substring.toLowerCase() == searchTerm.toLowerCase()) {
          result.write(html.substring(lastIndex, i));
          result.write('<mark style="background-color: rgba(255, 255, 0, 0.8); color: black; font-weight: bold; padding: 1px 2px; border-radius: 2px;">$substring</mark>');
          lastIndex = i + searchTerm.length;
          i += searchTerm.length - 1;
        }
      }
    }

    result.write(html.substring(lastIndex));
    return result.toString();
  }
}
