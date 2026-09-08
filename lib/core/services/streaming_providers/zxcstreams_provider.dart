import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/video_source_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/language_utils.dart';

class ZXCStreamsProvider {
  final Dio _dio = Dio();

  static const String _baseUrl = ApiConstants.baseUrl;

  Future<List<VideoSource>> fetchStreams({
    required String tmdbId,
    required String type,
    int? season,
    int? episode,
    String? originalLanguage,
    CancelToken? cancelToken,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'tmdb_id': tmdbId,
        'type': type,
        'provider': 'zxcstreams',
      };

      if (type == 'tv') {
        if (season != null) queryParams['season'] = season.toString();
        if (episode != null) queryParams['episode'] = episode.toString();
      }

      final response = await _dio.get(
        '$_baseUrl/api/stream',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['results'] != null) {
          final zxcResults = data['results']['zxcstreams'];
          if (zxcResults != null && zxcResults['success'] == true) {
            final List streamsList = zxcResults['streams'] ?? [];

            final Map<String, List<VideoQuality>> nameToQualities = {};
            final Map<String, Map<String, String>> nameToHeaders = {};

            for (var stream in streamsList) {
              final String rawName = stream['name'] ?? 'ZXCStreams';
              final String qualityLabel = stream['quality'] ?? '1080p';
              final String url = stream['url'] ?? '';

              // Group by name without quality suffix
              final String name = rawName.replaceAll(qualityLabel, '').trim();

              final Map<String, String> headers = {};
              if (stream['headers'] != null) {
                (stream['headers'] as Map).forEach((k, v) {
                  headers[k.toString()] = v.toString();
                });
              }

              // Ensure default headers if missing, although they should come from API
              headers['Referer'] ??= 'https://r1.zxcstream.xyz/';
              headers['Origin'] ??= 'https://r1.zxcstream.xyz';

              nameToQualities.putIfAbsent(name, () => []);

              // Check for duplicates based on URL OR Label to avoid confusing UI
              final isDuplicate = nameToQualities[name]!.any(
                (q) => q.url == url || q.label == qualityLabel,
              );

              if (!isDuplicate) {
                nameToQualities[name]!.add(
                  VideoQuality(
                    label: qualityLabel,
                    url: url,
                    isAuto: qualityLabel.toLowerCase().contains('auto'),
                  ),
                );
              }
              nameToHeaders.putIfAbsent(name, () => headers);
            }

            List<VideoSource> sources = nameToQualities.entries.map((entry) {
              final name = entry.key;
              final qualities = entry.value;

              // Sort qualities: Auto first, then descending resolution
              qualities.sort((a, b) {
                if (a.isAuto) return -1;
                if (b.isAuto) return 1;
                return _extractRes(b.label).compareTo(_extractRes(a.label));
              });

              return VideoSource(
                name: name,
                hlsUrl: qualities.first.url,
                headers: nameToHeaders[name] ?? {},
                qualities: qualities,
                subtitles: [],
              );
            }).toList();

            // Language Matching logic
            if (originalLanguage != null && originalLanguage.isNotEmpty) {
              sources.sort((a, b) {
                final aScore = LanguageUtils.getLanguageScore(
                  a.name ?? '',
                  originalLanguage,
                );
                final bScore = LanguageUtils.getLanguageScore(
                  b.name ?? '',
                  originalLanguage,
                );
                return bScore.compareTo(aScore);
              });
            }

            return sources;
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('ZXCStreams Provider Error: $e');
      return [];
    }
  }

  int _extractRes(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
