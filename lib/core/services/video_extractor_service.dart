import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_source_model.dart';

class VideoScraperService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://redesigned-rotary-phone-pj4799xggwpp26pgr-4000.app.github.dev';

  Future<List<VideoSource>> extractSources({
    required String type, // 'movie' or 'tv'
    required String tmdbId,
    int? season,
    int? episode,
  }) async {
    try {
      final queryParams = {
        'type': type,
        'tmdb_id': tmdbId,
      };

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
        Map<String, dynamic> rawResults = {};

        // Safe Results Map Parsing
        if (rawData is Map) {
          rawResults = Map<String, dynamic>.from(rawData);
        } else if (rawData is String && rawData.isNotEmpty) {
          try {
            final decoded = jsonDecode(rawData);
            if (decoded is Map) {
              rawResults = Map<String, dynamic>.from(decoded);
            }
          } catch (_) {}
        } else if (rawData is List) {
          // Handle case where results is a List directly
          final List<VideoSource> sources = [];
          for (var item in rawData) {
            try {
              if (item is Map<String, dynamic>) {
                sources.add(VideoSource.fromJson(item));
              }
            } catch (e) {
              debugPrint('Error parsing individual source from list: $e');
            }
          }
          return sources;
        }

        final List<VideoSource> sources = [];
        rawResults.forEach((key, value) {
          try {
            if (value is Map) {
              final sourceData = Map<String, dynamic>.from(value);
              if (sourceData['name'] == null) {
                sourceData['name'] = key;
              }
              sources.add(VideoSource.fromJson(sourceData));
            } else if (value is String) {
              // Handle case where individual provider data might be a JSON string
              final decodedValue = jsonDecode(value);
              if (decodedValue is Map) {
                final sourceData = Map<String, dynamic>.from(decodedValue);
                if (sourceData['name'] == null) {
                  sourceData['name'] = key;
                }
                sources.add(VideoSource.fromJson(sourceData));
              }
            }
          } catch (e) {
            debugPrint('Error parsing source for provider $key: $e');
          }
        });
        
        return sources;
      }
      return [];
    } catch (e) {
      debugPrint('Stream extraction error: $e');
      return [];
    }
  }
}
