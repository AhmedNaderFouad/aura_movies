import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/video_source_model.dart';
import '../utils/language_utils.dart';
import '../utils/video_header_utility.dart';

class MediaPlaybackService {
  static final Dio _dio = Dio();

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
        if (content.contains('#EXT-X-STREAM-INF:')) {
          final lines = content.split('\n');
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('#EXT-X-STREAM-INF:')) {
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
      debugPrint('Manifest unwrapping failed: $e');
    }
    return url;
  }

  static Future<VideoPlayerController> initializeController({
    required VideoSource source,
    String? specificUrl,
    String? specificAudioUrl,
  }) async {
    String? url = specificUrl ?? source.hlsUrl;
    final String? audioUrl = specificAudioUrl ?? source.audioUrl;

    if (url == null || url.isEmpty) {
      throw Exception('URL is null or empty');
    }

    final headers = VideoHeaderUtility.getHeaders(url, source);
    debugPrint('MediaPlaybackService: Initializing with URL: $url');

    bool isHls = false;
    String finalUrl = url;

    // 1. Resolve direct Media Playlist and Detect HLS
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
        if (content.contains('#EXTM3U')) {
          isHls = true;
          if (content.contains('#EXT-X-STREAM-INF')) {
            final lines = content.split('\n');
            for (var line in lines) {
              final trimmed = line.trim();
              if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
                finalUrl = Uri.parse(url).resolve(trimmed).toString();
                debugPrint(
                  'MediaPlaybackService: Unwrapped Master Playlist to: $finalUrl',
                );
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint(
        'MediaPlaybackService: Pre-initialization unwrapping skipped/failed: $e',
      );
    }

    // 2. Handle side-loaded audio
    if (audioUrl != null && audioUrl.isNotEmpty) {
      isHls = true; // Manifest we create below is HLS
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
    } else if (finalUrl == url) {
      finalUrl = await unwrapManifest(url, headers);
    }

    VideoFormat? hint =
        (isHls || finalUrl.contains('.m3u8') || finalUrl.startsWith('data:'))
        ? VideoFormat.hls
        : null;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(finalUrl),
      httpHeaders: headers,
      formatHint: hint,
    );

    debugPrint('[PLAYBACK] Starting player initialization');
    await controller.initialize();

    debugPrint('[PLAYBACK] Player initialized. Forcing PAUSED state.');
    await controller.pause(); // Explicitly ensure it's paused

    final bool isActuallyPlaying = controller.value.isPlaying;
    debugPrint(
      '[PLAYBACK] Player initialization complete. isPlaying: $isActuallyPlaying',
    );

    return controller;
  }
}
