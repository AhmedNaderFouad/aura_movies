import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubtitleStyleOptions {
  final double fontSize;
  final double bottomPadding;
  final double backgroundOpacity;
  final Color textColor;

  static const String _keyFontSize = 'subtitle_font_size';
  static const String _keyBottomPadding = 'subtitle_bottom_padding';
  static const String _keyBackgroundOpacity = 'subtitle_background_opacity';

  const SubtitleStyleOptions({
    this.fontSize = 24.0,
    this.bottomPadding = 30.0,
    this.backgroundOpacity = 0.45,
    this.textColor = Colors.white,
  });

  SubtitleStyleOptions copyWith({
    double? fontSize,
    double? bottomPadding,
    double? backgroundOpacity,
    Color? textColor,
  }) {
    return SubtitleStyleOptions(
      fontSize: fontSize ?? this.fontSize,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      textColor: textColor ?? this.textColor,
    );
  }

  /// Loads saved preferences from SharedPreferences
  static Future<SubtitleStyleOptions> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return SubtitleStyleOptions(
        fontSize: prefs.getDouble(_keyFontSize) ?? 24.0,
        bottomPadding: prefs.getDouble(_keyBottomPadding) ?? 30.0,
        backgroundOpacity: prefs.getDouble(_keyBackgroundOpacity) ?? 0.45,
      );
    } catch (e) {
      return const SubtitleStyleOptions();
    }
  }

  /// Saves current preferences to SharedPreferences
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, fontSize);
      await prefs.setDouble(_keyBottomPadding, bottomPadding);
      await prefs.setDouble(_keyBackgroundOpacity, backgroundOpacity);
    } catch (_) {}
  }
}
