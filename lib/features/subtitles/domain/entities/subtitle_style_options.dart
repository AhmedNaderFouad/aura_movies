import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubtitleStyleOptions {
  final double fontSize;
  final double bottomPadding;
  final double backgroundOpacity;
  final double syncOffset;
  final Color textColor;

  static const String _keyFontSize = 'subtitle_font_size';
  static const String _keyBottomPadding = 'subtitle_bottom_padding';
  static const String _keyBackgroundOpacity = 'subtitle_background_opacity';
  static const String _keySyncOffset = 'subtitle_sync_offset';

  const SubtitleStyleOptions({
    this.fontSize = 24.0,
    this.bottomPadding = 30.0,
    this.backgroundOpacity = 0.45,
    this.syncOffset = 0.0,
    this.textColor = Colors.white,
  });

  SubtitleStyleOptions copyWith({
    double? fontSize,
    double? bottomPadding,
    double? backgroundOpacity,
    double? syncOffset,
    Color? textColor,
  }) {
    return SubtitleStyleOptions(
      fontSize: fontSize ?? this.fontSize,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      syncOffset: syncOffset ?? this.syncOffset,
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
        syncOffset: prefs.getDouble(_keySyncOffset) ?? 0.0,
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
      await prefs.setDouble(_keySyncOffset, syncOffset);
    } catch (_) {}
  }
}
