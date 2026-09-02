import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/video_source_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/language_utils.dart';

class ShowboxProvider {
  final Dio _dio = Dio();

  static const String _baseUrl = ApiConstants.baseUrl;

  Future<List<VideoSource>> fetchStreams({
    required String tmdbId,
    required String type,
    int? season,
    int? episode,
    String? originalLanguage,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'tmdb_id': tmdbId,
        'type': type,
        'provider': 'showbox',
      };

      if (type == 'tv') {
        if (season != null) queryParams['season'] = season.toString();
        if (episode != null) queryParams['episode'] = episode.toString();
      }

      final response = await _dio.get(
        '$_baseUrl/api/stream',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['results'] != null) {
          final showboxResults = data['results']['showbox'];
          if (showboxResults != null && showboxResults['success'] == true) {
            final List streamsList = showboxResults['streams'] ?? [];

            // Grouping: The backend now returns consolidated streams with 'audioTracks'.
            // However, we still want to provide separate entries in the Flutter UI for different languages
            // if the user prefers that, OR we can show one source and handle audio switching.
            // Requirement 2 says: "Group identical video URLs together while exposing all available audio tracks... inside a structured audioTracks array"
            // For Flutter, we will map each language track to a distinct VideoSource to make it selectable in the quality/audio picker.

            final List<VideoSource> allSources = [];

            for (var s in streamsList) {
              final Map<String, dynamic> stream = s is Map<String, dynamic>
                  ? s
                  : Map<String, dynamic>.from(s);
              final List audioTracks = stream['audioTracks'] ?? [];

              if (audioTracks.isNotEmpty) {
                // Create a distinct VideoSource for EACH audio track to allow language selection in the UI
                for (var track in audioTracks) {
                  final String langName = track['languageName'] ?? 'Unknown';

                  final Map<String, String> headers = {};
                  if (stream['headers'] != null) {
                    (stream['headers'] as Map).forEach(
                      (k, v) => headers[k.toString()] = v.toString(),
                    );
                  }

                  allSources.add(
                    VideoSource(
                      name: 'Showbox [$langName]',
                      hlsUrl: stream['url'] ?? '',
                      audioUrl: track['uri'] ?? '',
                      headers: headers,
                      qualities: [
                        VideoQuality(
                          label: stream['quality'] ?? 'Auto',
                          url: stream['url'] ?? '',
                          audioUrl: track['uri'] ?? '',
                          isAuto:
                              (stream['quality'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('org') ||
                              (stream['quality'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('auto'),
                        ),
                      ],
                      subtitles: [],
                    ),
                  );
                }
              } else {
                // Fallback for streams without audioTracks array
                final Map<String, String> headers = {};
                if (stream['headers'] != null) {
                  (stream['headers'] as Map).forEach(
                    (k, v) => headers[k.toString()] = v.toString(),
                  );
                }

                allSources.add(
                  VideoSource(
                    name: 'Showbox [${stream['languageName'] ?? 'Unknown'}]',
                    hlsUrl: stream['url'] ?? '',
                    audioUrl: stream['audioUri'],
                    headers: headers,
                    qualities: [
                      VideoQuality(
                        label: stream['quality'] ?? 'Auto',
                        url: stream['url'] ?? '',
                        audioUrl: stream['audioUri'],
                        isAuto: (stream['quality'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains('org'),
                      ),
                    ],
                    subtitles: [],
                  ),
                );
              }
            }

            // Consolidate identical VideoSources (same Name + URL) into one with multiple Qualities
            final Map<String, VideoSource> consolidated = {};
            for (var source in allSources) {
              final String key = '${source.name}|${source.hlsUrl}';
              if (consolidated.containsKey(key)) {
                final existing = consolidated[key]!;
                final newQualities = List<VideoQuality>.from(existing.qualities)
                  ..addAll(source.qualities);
                consolidated[key] = existing.copyWith(qualities: newQualities);
              } else {
                consolidated[key] = source;
              }
            }

            final List<VideoSource> sources = consolidated.values.toList();

            // Sort qualities within each source and bind the best one to hlsUrl/audioUrl
            for (int i = 0; i < sources.length; i++) {
              final source = sources[i];
              final sortedQualities = List<VideoQuality>.from(source.qualities);

              sortedQualities.sort((a, b) {
                if (a.isAuto && !b.isAuto) return -1;
                if (!a.isAuto && b.isAuto) return 1;
                return _parseResolution(
                  b.label,
                ).compareTo(_parseResolution(a.label));
              });

              final best = sortedQualities.first;
              sources[i] = source.copyWith(
                hlsUrl: best.url,
                audioUrl: best.audioUrl,
                qualities: sortedQualities,
              );
            }

            // Global Language Matching Logic
            if (originalLanguage != null && originalLanguage.isNotEmpty) {
              sources.sort((a, b) {
                final int aScore = LanguageUtils.getLanguageScore(
                  a.name,
                  originalLanguage,
                );
                final int bScore = LanguageUtils.getLanguageScore(
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
      debugPrint('Showbox Provider Error: $e');
      return [];
    }
  }

  int _parseResolution(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
