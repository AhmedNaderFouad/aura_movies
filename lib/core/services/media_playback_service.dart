import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/video_source_model.dart';
import '../utils/video_header_utility.dart';

class MediaPlaybackService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  /// Resolves the final media URL, handling master playlist unwrapping for side-loaded audio
  static Future<String> unwrapManifest(
    String url,
    Map<String, String> headers,
  ) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final content = response.data.toString();
        if (content.contains('#EXT-X-STREAM-INF')) {
          final lines = content.split('\n');
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('#EXT-X-STREAM-INF')) {
              for (int j = i + 1; j < lines.length; j++) {
                final nextLine = lines[j].trim();
                if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
                  return nextLine.startsWith('http')
                      ? nextLine
                      : Uri.parse(url).resolve(nextLine).toString();
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[PLAYBACK] Manifest unwrapping failed: $e');
    }
    return url;
  }

  /// Factory-like method to prepare a VideoPlayerController with optimized initialization
  static Future<VideoPlayerController> initializeController({
    required VideoSource source,
    String? specificUrl,
    String? specificAudioUrl,
  }) async {
    final String url = specificUrl ?? source.hlsUrl ?? '';
    final String? audioUrl = specificAudioUrl ?? source.audioUrl;

    if (url.isEmpty) throw Exception('Media URL is missing');

    final headers = VideoHeaderUtility.getHeaders(url, source);
    bool isHls = false;
    String finalUrl = url;

    // 1. Optimized HLS Detection (only for 'Auto' or Master URLs)
    // If specificUrl is provided, we assume it's already the desired quality
    if (specificUrl == null) {
      try {
        final response = await _dio.head(
          url,
          options: Options(
            headers: headers,
            followRedirects: true,
            validateStatus: (status) => status! < 500,
          ),
        );

        if (response.statusCode == 200) {
          final contentType =
              response.headers.value('content-type')?.toLowerCase() ?? '';
          if (contentType.contains('mpegurl') ||
              contentType.contains('application/x-mpegurl') ||
              url.contains('.m3u8')) {
            isHls = true;
          }

          if (response.realUri.toString() != url) {
            finalUrl = response.realUri.toString();
          }
        }
      } catch (e) {
        if (url.contains('.m3u8')) isHls = true;
      }
    } else {
      // If we have a specific URL, it's likely a variant or direct link
      if (url.contains('.m3u8')) isHls = true;
    }

    // 2. Handle Audio Track Mixing (requires manual manifest injection)
    if (audioUrl != null && audioUrl.isNotEmpty) {
      isHls = true;
      final unwrappedVideoUrl = await unwrapManifest(finalUrl, headers);
      final unwrappedAudioUrl = await unwrapManifest(audioUrl, headers);

      final manifestContent =
          '''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Default",DEFAULT=YES,AUTOSELECT=YES,URI="$unwrappedAudioUrl"
#EXT-X-STREAM-INF:BANDWIDTH=10000000,RESOLUTION=1920x1080,AUDIO="audio",CODECS="avc1.4d401f,mp4a.40.2"
$unwrappedVideoUrl
''';
      finalUrl =
          'data:application/x-mpegURL;base64,${base64Encode(utf8.encode(manifestContent))}';
    }

    final VideoFormat? formatHint = (isHls || finalUrl.startsWith('data:'))
        ? VideoFormat.hls
        : null;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(finalUrl),
      httpHeaders: VideoHeaderUtility.getHeaders(finalUrl, source),
      formatHint: formatHint,
    );

    debugPrint('[PLAYBACK] Prepared controller instance for: $finalUrl');
    return controller;
  }
}
