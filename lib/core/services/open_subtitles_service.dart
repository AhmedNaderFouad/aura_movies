import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_source_model.dart';

class OpenSubtitlesService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.opensubtitles.com/api/v1';
  static const String _apiKey = 'ZIa45NH3pd1n3JTUxTT3TcK84UMJ65lR';

  Future<List<SubtitleModel>> searchSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
    String language = 'en,ar',
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {'languages': language};

      if (imdbId != null) {
        queryParameters['imdb_id'] = imdbId.replaceAll('tt', '');
      } else {
        queryParameters['tmdb_id'] = tmdbId;
      }

      if (isTv) {
        queryParameters['type'] = 'episode';
        if (season != null) queryParameters['season_number'] = season;
        if (episode != null) queryParameters['episode_number'] = episode;
      } else {
        queryParameters['type'] = 'movie';
      }

      final response = await _dio.get(
        '$_baseUrl/subtitles',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Api-Key': _apiKey,
            'User-Agent': 'AuraMovies v1.0.0',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('OpenSubtitles Search Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        debugPrint('OpenSubtitles: Found ${data.length} subtitles');
        return data.map((item) {
          final attributes = item['attributes'];
          final files = attributes['files'] as List?;
          final file = (files != null && files.isNotEmpty) ? files[0] : null;

          return SubtitleModel(
            language: '${attributes['language']} - ${attributes['release']}',
            fileId: file?['file_id']?.toString(),
            url: (attributes['url'] ?? attributes['link'])
                ?.toString(), // Use link/url as fallback
            server: SubtitleServer.openSubtitles,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('OpenSubtitles Search Error: $e');
      return [];
    }
  }

  Future<String?> getDownloadUrl(String fileId) async {
    try {
      debugPrint(
        'OpenSubtitles: Requesting download link for file_id: $fileId',
      );

      final response = await _dio.post(
        '$_baseUrl/download',
        data: {'file_id': int.tryParse(fileId) ?? 0},
        options: Options(
          headers: {
            'Api-Key': _apiKey,
            'User-Agent': 'AuraMovies v1.0.0',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => true, // Manually handle all status codes
        ),
      );

      debugPrint('OpenSubtitles Download HTTP Status: ${response.statusCode}');
      debugPrint('OpenSubtitles Download Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final link = response.data['link'] as String?;
        debugPrint('OpenSubtitles: Successfully obtained link: $link');
        return link;
      } else {
        final errorMsg =
            response.data['message'] ??
            response.data['errors'] ??
            'Unknown error';
        debugPrint('OpenSubtitles Download Error Detail: $errorMsg');

        if (response.statusCode == 401 || response.statusCode == 406) {
          debugPrint(
            'OpenSubtitles: Header/User-Agent/API Key issue detected (401/406)',
          );
        } else if (response.statusCode == 429 || response.statusCode == 403) {
          debugPrint('OpenSubtitles: Quota/Rate Limit exceeded (429/403)');
        }
      }
    } catch (e) {
      debugPrint('OpenSubtitles Download Exception: $e');
    }
    return null;
  }
}
