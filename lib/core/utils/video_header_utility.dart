import '../models/video_source_model.dart';

class VideoHeaderUtility {
  /// Generates optimized headers for a specific media URL based on its provider
  static Map<String, String> getHeaders(String url, VideoSource source) {
    final Map<String, String> headers = {};

    // 1. Initialize with source-specific headers
    source.headers.forEach((key, value) {
      headers[key] = value;
    });

    // 2. Identify and normalize critical browser headers
    String? referer;
    String? origin;
    String? userAgent;

    final keysToRemove = <String>[];
    headers.forEach((k, v) {
      final lowKey = k.toLowerCase();
      if (lowKey == 'referer') {
        referer = v;
      } else if (lowKey == 'origin') {
        origin = v;
      } else if (lowKey == 'user-agent') {
        userAgent = v;
      }

      if (lowKey == 'referer' || lowKey == 'origin' || lowKey == 'user-agent') {
        keysToRemove.add(k);
      }
    });

    for (var k in keysToRemove) {
      headers.remove(k);
    }

    // 3. Set Industry-Standard Default User Agent (Chrome 129)
    final finalUserAgent =
        userAgent ??
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36';

    headers['User-Agent'] = finalUserAgent;
    if (referer != null) {
      headers['Referer'] = referer!;
    }
    if (origin != null) {
      headers['Origin'] = origin!;
    }

    // 4. Provider-Specific Optimizations
    final bool isShowbox =
        url.contains('shegu.net') ||
        url.contains('febbox.com') ||
        url.contains('showbox');

    if (isShowbox) {
      headers.addAll({
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Language': 'en-US,en;q=0.9',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'cross-site',
        'Origin': 'https://www.febbox.com',
        'Referer': 'https://www.febbox.com/',
        'sec-ch-ua':
            '"Chromium";v="129", "Not:A-Brand";v="8", "Google Chrome";v="129"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'X-Requested-With': 'XMLHttpRequest',
      });

      // Prevent unnecessary compression that CDNs might struggle with in HLS
      headers.remove('Accept-Encoding');
    }

    return headers;
  }
}
