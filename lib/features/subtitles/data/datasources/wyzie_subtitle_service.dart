import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/subtitle_model.dart';

class SubtitleService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://sub.wyzie.ru/search';
  static const String _apiKey = 'wyzie-8t3o0xj0bnyz6g0qe08dotei43ls6cxp';

  Future<List<SubtitleModel>> fetchSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
  }) async {
    try {
      final String id = (imdbId != null && imdbId.isNotEmpty) ? imdbId : tmdbId;

      final Map<String, dynamic> queryParameters = {'id': id, 'key': _apiKey};

      if (isTv) {
        if (season != null) queryParameters['season'] = season.toString();
        if (episode != null) queryParameters['episode'] = episode.toString();
      }

      debugPrint('Subtitle Request URL: $_baseUrl');
      debugPrint('Subtitle Request Params: $queryParameters');

      final response = await _dio.get(
        _baseUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      debugPrint('Subtitle API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> results = [];

        if (data is List) {
          results = data;
        } else if (data is Map) {
          if (data['results'] is List) {
            results = data['results'];
          } else if (data['subtitles'] is List) {
            results = data['subtitles'];
          } else if (data['data'] is List) {
            results = data['data'];
          }
        }

        if (results.isNotEmpty) {
          final subs = results
              .map((e) {
                try {
                  return SubtitleModel.fromJson(Map<String, dynamic>.from(e));
                } catch (e) {
                  debugPrint('Error parsing individual subtitle: $e');
                  return null;
                }
              })
              .whereType<SubtitleModel>()
              .toList();

          debugPrint('Found ${subs.length} external subtitles');
          return subs;
        }
      }

      debugPrint(
        'No external subtitles found or error occurred. Response: ${response.data}',
      );
      return [];
    } catch (e) {
      debugPrint('Subtitle Fetch Exception: $e');
      return [];
    }
  }
}
