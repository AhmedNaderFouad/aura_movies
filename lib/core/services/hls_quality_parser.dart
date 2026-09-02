import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_source_model.dart';
import '../utils/video_header_utility.dart';

class HlsQualityParser {
  final Dio _dio = Dio();

  Future<List<VideoQuality>> parseQualities(
    String masterUrl,
    VideoSource source,
  ) async {
    final List<VideoQuality> qualities = [];
    final Set<String> seenUrls = {};
    final Set<String> seenLabels = {};

    // 1. Determine the "Auto" entry
    VideoQuality? sourceAuto = source.qualities.firstWhere(
      (q) =>
          q.isAuto ||
          q.label.toLowerCase().contains('auto') ||
          q.url.contains('master.m3u8'),
      orElse: () => VideoQuality(label: 'Auto', url: masterUrl, isAuto: true),
    );

    qualities.add(
      VideoQuality(label: 'Auto', url: sourceAuto.url, isAuto: true),
    );
    seenUrls.add(sourceAuto.url);
    seenLabels.add('auto');

    if (!sourceAuto.url.contains('.m3u8')) return qualities;

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

      if (response.statusCode == 200) {
        // Capture cookies for subsequent segment requests
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          final cookieString = cookies.map((c) => c.split(';')[0]).join('; ');
          source.headers['Cookie'] = cookieString;
          debugPrint('Captured CDN session cookies: $cookieString');
        }

        final content = response.data.toString();
        if (content.contains('#EXT-X-STREAM-INF:')) {
          final lines = content.split('\n');
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.startsWith('#EXT-X-STREAM-INF:')) {
              String label = _extractLabelFromInf(line);
              String? variantUrl = _extractUrlFromInf(lines, i, sourceAuto.url);

              if (variantUrl != null) {
                if (!seenUrls.contains(variantUrl) &&
                    !seenLabels.contains(label.toLowerCase())) {
                  qualities.add(VideoQuality(label: label, url: variantUrl));
                  seenUrls.add(variantUrl);
                  seenLabels.add(label.toLowerCase());
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('HLS Quality Parsing Error: $e');
    }

    // Merge static qualities from source
    for (var q in source.qualities) {
      if (!q.isAuto && !seenLabels.contains(q.label.toLowerCase())) {
        qualities.add(q);
        seenUrls.add(q.url);
        seenLabels.add(q.label.toLowerCase());
      }
    }

    // Sorting
    if (qualities.length > 1) {
      final auto = qualities.firstWhere((q) => q.isAuto);
      final staticQuals = qualities.where((q) => !q.isAuto).toList();
      staticQuals.sort(
        (a, b) =>
            _extractResolution(b.label).compareTo(_extractResolution(a.label)),
      );
      qualities.clear();
      qualities.add(auto);
      qualities.addAll(staticQuals);
    }

    return qualities;
  }

  String _extractLabelFromInf(String line) {
    final resMatch = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
    if (resMatch != null) {
      return '${resMatch.group(1)!.split('x')[1]}p';
    }
    final bwMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
    if (bwMatch != null) {
      final bw = int.parse(bwMatch.group(1)!);
      if (bw > 5000000) return '2160p';
      if (bw > 2500000) return '1080p';
      if (bw > 1000000) return '720p';
      if (bw > 600000) return '480p';
      return '360p';
    }
    return 'Unknown';
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
