import 'package:flutter/foundation.dart';

class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleCue({required this.start, required this.end, required this.text});
}

class SubtitleParser {
  static List<SubtitleCue> parse(String content) {
    if (content.isEmpty) return [];

    List<SubtitleCue> cues;
    if (content.contains('WEBVTT')) {
      cues = _parseVTT(content);
    } else {
      cues = _parseSRT(content);
    }

    // Ensure cues are sorted by start time for optimized binary search
    cues.sort((a, b) => a.start.compareTo(b.start));
    return cues;
  }

  static List<SubtitleCue> _parseSRT(String content) {
    final List<SubtitleCue> cues = [];
    // Normalize newlines and split into blocks
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.trim().split(RegExp(r'\n\n+'));

    for (var block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      String timeLine = '';
      int textStartLine = -1;

      // Find the line containing "-->"
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          timeLine = lines[i];
          textStartLine = i + 1;
          break;
        }
      }

      if (timeLine.isNotEmpty &&
          textStartLine != -1 &&
          textStartLine < lines.length) {
        final times = timeLine.split('-->');
        if (times.length == 2) {
          try {
            final start = _parseDuration(times[0].trim().replaceAll(',', '.'));
            final end = _parseDuration(
              times[1].trim().split(RegExp(r'\s+')).first.replaceAll(',', '.'),
            );

            final text = lines
                .sublist(textStartLine)
                .join('\n')
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .trim();

            if (text.isNotEmpty) {
              cues.add(SubtitleCue(start: start, end: end, text: text));
            }
          } catch (e) {
            debugPrint('[SubtitleParser] Error parsing SRT block: $e');
          }
        }
      }
    }
    return cues;
  }

  static List<SubtitleCue> _parseVTT(String content) {
    final List<SubtitleCue> cues = [];
    final normalized = content.replaceFirst('WEBVTT', '').trim();
    final blocks = normalized.split(RegExp(r'\n\s*\n'));

    for (var block in blocks) {
      final lines = block.split('\n');
      String timeLine = '';
      int textStartLine = 0;

      if (lines[0].contains('-->')) {
        timeLine = lines[0];
        textStartLine = 1;
      } else if (lines.length > 1 && lines[1].contains('-->')) {
        timeLine = lines[1];
        textStartLine = 2;
      }

      if (timeLine.isNotEmpty) {
        final times = timeLine.split(' --> ');
        if (times.length == 2) {
          final start = _parseDuration(times[0]);
          final end = _parseDuration(times[1].split(' ').first);
          final text = lines
              .sublist(textStartLine)
              .join('\n')
              .replaceAll(RegExp(r'<[^>]*>'), '');
          cues.add(SubtitleCue(start: start, end: end, text: text.trim()));
        }
      }
    }
    return cues;
  }

  static Duration _parseDuration(String time) {
    final parts = time.trim().split(':');
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secondsParts = parts[2].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = secondsParts.length > 1
          ? int.parse(secondsParts[1].padRight(3, '0').substring(0, 3))
          : 0;
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } else if (parts.length == 2) {
      final minutes = int.parse(parts[0]);
      final secondsParts = parts[1].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = secondsParts.length > 1
          ? int.parse(secondsParts[1].padRight(3, '0').substring(0, 3))
          : 0;
      return Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    }
    return Duration.zero;
  }
}
