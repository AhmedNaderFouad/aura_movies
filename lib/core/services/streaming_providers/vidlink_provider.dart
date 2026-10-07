import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/video_source_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/language_utils.dart';

class VidLinkProvider {
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
        'provider': 'vidlink',
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
        if (data['success'] == true) {
          List streamsList = [];

          if (data['results'] != null && data['results']['vidlink'] != null) {
            final vidlinkResults = data['results']['vidlink'];
            if (vidlinkResults['success'] == true) {
              streamsList = vidlinkResults['streams'] ?? [];
            }
          }

          // Fallback to top-level streams list if results.vidlink wasn't present
          if (streamsList.isEmpty && data['streams'] != null) {
            streamsList = data['streams'] ?? [];
          }

          if (streamsList.isNotEmpty) {
            final Map<String, List<VideoQuality>> nameToQualities = {};
            final Map<String, Map<String, String>> nameToHeaders = {};

            for (var stream in streamsList) {
              final String name = stream['name'] ?? 'VidLink';
              final String qualityLabel = stream['quality'] ?? 'Auto';
              final String url = stream['url'] ?? '';

              final Map<String, String> headers = {
                'User-Agent': 'VLC/3.0.20 LibVLC/3.0.20',
                'Accept': '*/*',
                'Accept-Language': 'en-US,en;q=0.9',
                'Connection': 'keep-alive',
              };

              nameToQualities.putIfAbsent(name, () => []);

              final isDuplicateUrl = nameToQualities[name]!.any(
                (q) => q.url == url,
              );

              if (!isDuplicateUrl) {
                nameToQualities[name]!.add(
                  VideoQuality(
                    label: qualityLabel,
                    url: url,
                    isAuto:
                        qualityLabel.toLowerCase().contains('auto') ||
                        url.contains('master.m3u8'),
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
                return _extractResolution(
                  b.label,
                ).compareTo(_extractResolution(a.label));
              });

              return VideoSource(
                name: name,
                hlsUrl: qualities.first.url,
                headers: nameToHeaders[name] ?? {},
                qualities: qualities,
                subtitles: [],
              );
            }).toList();

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
      debugPrint('VidLink Provider Error: $e');
      return [];
    }
  }

  int _extractResolution(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
