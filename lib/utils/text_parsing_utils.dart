import 'package:flutter/material.dart';

/// Shared utility functions for text parsing and formatting
class TextParsingUtils {
  /// Parse text with [b]...[/b] tags for bold formatting
  static Widget parseBold(String text, {bool isUrdu = false, bool isRoman = false}) {
    final regex = RegExp(r'\[b\](.*?)\[/b\]', dotAll: true, unicode: true);
    final spans = <TextSpan>[];
    int currentIndex = 0;

    // Auto-detect language if not specified
    final detectedUrdu = isUrdu || RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final detectedRoman = isRoman || (!detectedUrdu && RegExp(r'[a-zA-Z]').hasMatch(text));

    final normalFontSize = detectedUrdu ? 22.0 : (detectedRoman ? 22.0 : 24.0);
    final boldFontSize = detectedUrdu ? 26.0 : (detectedRoman ? 26.0 : 30.0);

    for (final match in regex.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: TextStyle(
            fontSize: normalFontSize,
            height: 1.2,
            fontWeight: FontWeight.w500,
            fontFamily: 'Edu',
            color: const Color(0xFF8B5E3C),
          ),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: boldFontSize,
          height: 1.5,
          fontWeight: FontWeight.w700,
          fontFamily: 'Edu',
          color: const Color(0xFF8B5E3C),
        ),
      ));

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(
          fontSize: normalFontSize,
          height: 1.2,
          fontWeight: FontWeight.w500,
          fontFamily: 'Edu',
          color: const Color(0xFF8B5E3C),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
