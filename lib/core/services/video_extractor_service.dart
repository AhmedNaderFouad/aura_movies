import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_source_model.dart';

class VideoScraperService {
  final Dio _dio = Dio();
  static const String baseUrl =
      'https://friendly-space-xylophone-g4jx66g55x7gf76q-4000.app.github.dev';

  Future<VideoSource?> extractVidsrcSource({
    required String type, // 'movie' or 'tv'
    required String tmdbId,
    int? season,
    int? episode,
  }) async {
    try {
      final queryParams = {'type': type, 'tmdb_id': tmdbId};

      if (type == 'tv') {
        queryParams['season'] = season.toString();
        queryParams['episode'] = episode.toString();
      }

      final response = await _dio.get(
        '$baseUrl/extract',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawData = response.data['results'];

        if (rawData is Map) {
          // Look for vidsrc.pm specifically
          var vidsrcData = rawData['vidsrc.pm'] ?? rawData['vidsrc'];
          if (vidsrcData != null) {
            if (vidsrcData is String && !vidsrcData.trim().startsWith('{')) {
              return VideoSource(
                name: 'VidSrc (Primary)',
                hlsUrl: vidsrcData.trim(),
                subtitles: [],
              );
            }

            final sourceMap = Map<String, dynamic>.from(
              vidsrcData is String ? jsonDecode(vidsrcData) : vidsrcData,
            );
            sourceMap['name'] = sourceMap['name'] ?? 'VidSrc (Primary)';
            return VideoSource.fromJson(sourceMap);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Vidsrc extraction error: $e');
      return null;
    }
  }
}
