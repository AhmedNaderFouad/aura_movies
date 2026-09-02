import 'package:flutter/material.dart';
import '../../../lib/features/subtitles/data/datasources/subtitle_parser.dart';

void main() {
  const srt = """
1
00:00:01,500 --> 00:00:02,000
Hello World

2
00:00:05.100 --> 00:00:06.000
Second subtitle
""";

  const vtt = """
WEBVTT

00:01.000 --> 00:02.500
VTT subtitle without hours

00:00:05.000 --> 00:00:06.000
VTT with hours
""";

  print('Testing SRT Parsing...');
  final srtCues = SubtitleParser.parse(srt);
  for (var cue in srtCues) {
    print('Cue: ${cue.start} -> ${cue.end}: ${cue.text}');
  }

  print('\nTesting VTT Parsing...');
  final vttCues = SubtitleParser.parse(vtt);
  for (var cue in vttCues) {
    print('Cue: ${cue.start} -> ${cue.end}: ${cue.text}');
  }

  print('\nTesting Minimum Duration (1.5s)...');
  // First SRT cue is 500ms (1.5s to 2.0s). Should be adjusted to 1.5s -> 3.0s.
  print('Original 1st SRT cue end: ${srtCues[0].end}');
  
  print('\nTesting Framerate Scale (1.1x)...');
  final scaledCues = SubtitleParser.parse(srt, framerateScale: 1.1);
  print('Original 1st SRT start: ${srtCues[0].start}');
  print('Scaled 1st SRT start: ${scaledCues[0].start}');
}
