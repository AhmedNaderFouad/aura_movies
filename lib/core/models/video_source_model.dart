import 'dart:convert';
import '../../features/subtitles/data/models/subtitle_model.dart';

class VideoSource {
  final String? name;
  final String? hlsUrl;
  final List<SubtitleModel> subtitles;
  final Map<String, String> headers;

  VideoSource({
    this.name,
    this.hlsUrl,
    required this.subtitles,
    this.headers = const {},
  });

  VideoSource copyWith({
    String? name,
    String? hlsUrl,
    List<SubtitleModel>? subtitles,
    Map<String, String>? headers,
  }) {
    return VideoSource(
      name: name ?? this.name,
      hlsUrl: hlsUrl ?? this.hlsUrl,
      subtitles: subtitles ?? this.subtitles,
      headers: headers ?? this.headers,
    );
  }

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    var subtitleList = json['subtitles'] as List? ?? [];

    // Safe Header Parsing
    Map<String, String> parsedHeaders = {};
    final rawHeaders = json['headers'];
    if (rawHeaders is Map) {
      parsedHeaders = rawHeaders.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    } else if (rawHeaders is String && rawHeaders.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawHeaders);
        if (decoded is Map) {
          parsedHeaders = decoded.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        }
      } catch (_) {}
    }

    return VideoSource(
      name: json['name'] as String?,
      hlsUrl: json['hls_url'] as String?,
      subtitles: subtitleList.map((e) => SubtitleModel.fromJson(e)).toList(),
      headers: parsedHeaders,
    );
  }
}
