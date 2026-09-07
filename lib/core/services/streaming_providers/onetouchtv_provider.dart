import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/video_source_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/language_utils.dart';

class OneTouchTVProvider {
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
        'provider': 'onetouchtv',
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
          final oneTouchResults = data['results']['onetouchtv'];
          if (oneTouchResults != null && oneTouchResults['success'] == true) {
            final List streamsList = oneTouchResults['streams'] ?? [];

            final Map<String, List<VideoQuality>> nameToQualities = {};
            final Map<String, Map<String, String>> nameToHeaders = {};

            for (var stream in streamsList) {
              final String name = stream['name'] ?? 'OneTouchTV';
              final String qualityLabel = stream['quality'] ?? 'Auto';
              final String url = stream['url'] ?? '';

              final Map<String, String> headers = {};
              if (stream['headers'] != null) {
                (stream['headers'] as Map).forEach((k, v) {
                  headers[k.toString()] = v.toString();
                });
              }
              headers['Referer'] ??= 'https://api3.devcorp.me/';

              nameToQualities.putIfAbsent(name, () => []);
              final isDuplicate = nameToQualities[name]!.any(
                (q) =>
                    q.label.toLowerCase() == qualityLabel.toLowerCase() ||
                    q.url == url,
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

              qualities.sort((a, b) {
                if (a.isAuto) return -1;
                if (b.isAuto) return 1;
                return _parseRes(b.label).compareTo(_parseRes(a.label));
              });

              return VideoSource(
                name: name,
                hlsUrl: qualities.first.url,
                headers: nameToHeaders[name] ?? {},
                qualities: qualities,
                subtitles: [],
              );
            }).toList();

            // Isolated Ranking logic using centralized utility
            if (originalLanguage != null && originalLanguage.isNotEmpty) {
              sources.sort((a, b) {
                final aScore = LanguageUtils.getLanguageScore(
                  a.name,
                  originalLanguage,
                );
                final bScore = LanguageUtils.getLanguageScore(
                  b.name,
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
      debugPrint('OneTouchTV Provider Error: $e');
      return [];
    }
  }

  int _parseRes(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
