import '../constants/api_constants.dart';

class LanguageUtils {
  /// Calculates a priority score for a stream based on its text (name/title)
  /// and the media's original language code.
  ///
  /// Priority 1 (Exact Match): Score 15-20
  /// Priority 2 (Default/Undefined): Score 10
  /// Priority 3 (Fallback/Mismatched): Score 0
  static int getLanguageScore(String? text, String? langCode) {
    if (text == null || langCode == null || langCode.isEmpty) return 10;

    final lowerText = text.toLowerCase();
    final lowerLang = langCode.toLowerCase();

    final keywords = ApiConstants.languageMap[lowerLang] ?? [lowerLang];

    // Priority 1: Explicit bracketed or parenthesized code match (e.g. [es] or (es))
    if (lowerText.contains('[$lowerLang]') ||
        lowerText.contains('($lowerLang)')) {
      return 20;
    }

    // Priority 1: Full language name or keyword match (e.g. "Spanish")
    for (final kw in keywords) {
      if (lowerText.contains(kw)) return 15;
    }

    // Priority 2: Default/Undefined. If the text doesn't contain ANY other language tags,
    // it's likely the original/main stream.
    if (!_hasAnyOtherLanguageTag(lowerText, lowerLang)) {
      return 10;
    }

    // Priority 3: Mismatched language tag found.
    return 0;
  }

  static bool _hasAnyOtherLanguageTag(String text, String currentLang) {
    for (final entry in ApiConstants.languageMap.entries) {
      if (entry.key == currentLang) continue;

      // Check for code in brackets/parens
      if (text.contains('[${entry.key}]') || text.contains('(${entry.key})')) {
        return true;
      }

      // Check for keywords
      for (final kw in entry.value) {
        if (text.contains(kw)) return true;
      }
    }
    return false;
  }
}
