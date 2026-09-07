import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_source_model.dart';
import '../utils/video_header_utility.dart';

class HlsQualityParser {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Parses a Master HLS playlist to extract variant stream URLs for different qualities
  Future<List<VideoQuality>> parseQualities(
    String masterUrl,
    VideoSource source,
  ) async {
    final List<VideoQuality> qualities = [];
    final Set<String> seenUrls = {};
    final Set<String> seenLabels = {};

    // 1. Identify the primary "Auto" (Master) URL
    VideoQuality? sourceAuto = source.qualities.firstWhere(
      (q) =>
          q.isAuto ||
          q.label.toLowerCase().contains('auto') ||
          q.url.contains('master.m3u8'),
      orElse: () => VideoQuality(label: 'Auto', url: masterUrl, isAuto: true),
    );

    // Always keep the master URL as 'Auto'
    qualities.add(
      VideoQuality(label: 'Auto', url: sourceAuto.url, isAuto: true),
    );
    seenUrls.add(sourceAuto.url);
    seenLabels.add('auto');

    // 2. Parse Manifest if it looks like an HLS Master Playlist
    if (sourceAuto.url.contains('.m3u8') ||
        sourceAuto.isAuto ||
        sourceAuto.label.toLowerCase().contains('auto')) {
      try {
        final headers = VideoHeaderUtility.getHeaders(sourceAuto.url, source);
        final response = await _dio.get(
          sourceAuto.url,
          options: Options(
            headers: headers,
            followRedirects: true,
            validateStatus: (status) => status! < 500,
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final content = response.data.toString();
          if (content.contains('#EXTM3U')) {
            // Logic to parse variant playlists
            if (content.contains('#EXT-X-STREAM-INF:')) {
              final lines = content.split('\n');
              for (int i = 0; i < lines.length; i++) {
                final line = lines[i].trim();
                if (line.startsWith('#EXT-X-STREAM-INF:')) {
                  String label = _extractLabelFromInf(line);
                  String? variantUrl = _extractUrlFromInf(
                    lines,
                    i,
                    sourceAuto.url,
                  );

                  if (variantUrl != null &&
                      variantUrl != sourceAuto.url &&
                      !seenUrls.contains(variantUrl)) {
                    // Prevent label collision by adding bitrate if resolution is same
                    String finalLabel = label;
                    if (seenLabels.contains(label.toLowerCase())) {
                      finalLabel = '$label (Alt)';
                    }

                    qualities.add(
                      VideoQuality(label: finalLabel, url: variantUrl),
                    );
                    seenUrls.add(variantUrl);
                    seenLabels.add(finalLabel.toLowerCase());
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[HLS_PARSER] Failed to parse manifest qualities: $e');
      }
    }

    // 3. Add static qualities from source that weren't found in manifest
    // This is critical for providers like NetMirror/ZXC that provide direct links already
    for (var q in source.qualities) {
      if (!q.isAuto && !seenUrls.contains(q.url)) {
        qualities.add(q);
        seenUrls.add(q.url);
        seenLabels.add(q.label.toLowerCase());
      }
    }

    // 4. Sort: Auto first, then descending by resolution
    if (qualities.length > 1) {
      final auto = qualities.firstWhere((q) => q.isAuto);
      final rest = qualities.where((q) => !q.isAuto).toList();

      rest.sort((a, b) {
        final resA = _extractResolution(a.label);
        final resB = _extractResolution(b.label);
        if (resA != resB) return resB.compareTo(resA);
        return a.label.compareTo(b.label);
      });

      qualities.clear();
      qualities.add(auto);
      qualities.addAll(rest);
    }

    return qualities;
  }

  String _extractLabelFromInf(String line) {
    // Attempt resolution first
    final resMatch = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
    if (resMatch != null) {
      final int height = int.parse(resMatch.group(1)!.split('x')[1]);
      if (height >= 2160) return '2160p';
      if (height >= 1440) return '1440p';
      if (height >= 1040) return '1080p';
      if (height >= 700) return '720p';
      if (height >= 450) return '480p';
      if (height >= 340) return '360p';
      return '${height}p';
    }

    // Fallback to bandwidth
    final bwMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
    if (bwMatch != null) {
      final bw = int.parse(bwMatch.group(1)!);
      if (bw > 5000000) return '4K';
      if (bw > 2800000) return '1080p';
      if (bw > 1200000) return '720p';
      if (bw > 600000) return '480p';
      return '360p';
    }
    return 'SD';
  }

  String? _extractUrlFromInf(List<String> lines, int index, String masterUrl) {
    for (int j = index + 1; j < lines.length; j++) {
      final nextLine = lines[j].trim();
      if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
        if (nextLine.startsWith('http')) return nextLine;
        return Uri.parse(masterUrl).resolve(nextLine).toString();
      }
    }
    return null;
  }

  int _extractResolution(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
