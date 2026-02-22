import 'package:flutter/material.dart';

class HighlightedTextWidget extends StatelessWidget {
  final String text;
  final String searchQuery;
  final TextStyle baseStyle;
  final TextStyle? highlightStyle;
  final bool caseSensitive;

  const HighlightedTextWidget({
    super.key,
    required this.text,
    required this.searchQuery,
    required this.baseStyle,
    this.highlightStyle,
    this.caseSensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final spans = _buildTextSpans();

    if (spans.length == 1) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(children: spans),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  List<TextSpan> _buildTextSpans() {
    final List<TextSpan> spans = [];
    final String processedText = caseSensitive ? text : text.toLowerCase();
    final String processedQuery = caseSensitive ? searchQuery : searchQuery.toLowerCase();
    
    int currentIndex = 0;
    final int queryLength = processedQuery.length;
    

    while (currentIndex < text.length) {
      final int matchIndex = processedText.indexOf(processedQuery, currentIndex);

      if (matchIndex == -1) {
        if (currentIndex < text.length) {
          spans.add(TextSpan(
            text: text.substring(currentIndex),
            style: baseStyle,
          ));
        }
        break;
      }

      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + queryLength),
        style: highlightStyle ?? baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      

      currentIndex = matchIndex + queryLength;
    }
    
    return spans;
  }
}

/// Extension for even simpler usage
extension HighlightedTextExtension on String {
  Widget highlighted({
    required String searchQuery,
    required TextStyle baseStyle,
    TextStyle? highlightStyle,
    bool caseSensitive = false,
  }) {
    return HighlightedTextWidget(
      text: this,
      searchQuery: searchQuery,
      baseStyle: baseStyle,
      highlightStyle: highlightStyle,
      caseSensitive: caseSensitive,
    );
  }
}
