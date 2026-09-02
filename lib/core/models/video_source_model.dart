import 'dart:convert';
import '../../features/subtitles/data/models/subtitle_model.dart';

class VideoQuality {
  final String label;
  final String url;
  final String? audioUrl;
  final bool isAuto;

  VideoQuality({
    required this.label,
    required this.url,
    this.audioUrl,
    this.isAuto = false,
  });

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      label: json['label']?.toString() ?? 'Unknown',
      url: json['url']?.toString() ?? '',
      audioUrl: json['audioUrl']?.toString(),
      isAuto: json['isAuto'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoQuality &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          url == other.url &&
          audioUrl == other.audioUrl &&
          isAuto == other.isAuto;

  @override
  int get hashCode =>
      label.hashCode ^ url.hashCode ^ audioUrl.hashCode ^ isAuto.hashCode;
}

class VideoSource {
  final String? name;
  final String? hlsUrl;
  final String? audioUrl;
  final List<SubtitleModel> subtitles;
  final Map<String, String> headers;
  final List<VideoQuality> qualities;

  VideoSource({
    this.name,
    this.hlsUrl,
    this.audioUrl,
    required this.subtitles,
    this.headers = const {},
    this.qualities = const [],
  });

  VideoSource copyWith({
    String? name,
    String? hlsUrl,
    String? audioUrl,
    List<SubtitleModel>? subtitles,
    Map<String, String>? headers,
    List<VideoQuality>? qualities,
  }) {
    return VideoSource(
      name: name ?? this.name,
      hlsUrl: hlsUrl ?? this.hlsUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      subtitles: subtitles ?? this.subtitles,
      headers: headers ?? this.headers,
      qualities: qualities ?? this.qualities,
    );
  }

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    var subtitleList = json['subtitles'] as List? ?? [];
    var qualityList = json['qualities'] as List? ?? [];

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
      audioUrl: json['audio_url'] as String?,
      subtitles: subtitleList.map((e) => SubtitleModel.fromJson(e)).toList(),
      headers: parsedHeaders,
      qualities: qualityList.map((e) => VideoQuality.fromJson(e)).toList(),
    );
  }
}
