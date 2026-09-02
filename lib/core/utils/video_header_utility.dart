import '../models/video_source_model.dart';

class VideoHeaderUtility {
  static Map<String, String> getHeaders(String url, VideoSource source) {
    final Map<String, String> headers = {};

    // 1. Collect all headers from source
    source.headers.forEach((key, value) {
      headers[key] = value;
    });

    // 2. Identify and normalize critical headers
    String? referer;
    String? origin;
    String? userAgent;

    final keysToRemove = <String>[];
    headers.forEach((k, v) {
      final lowKey = k.toLowerCase();
      if (lowKey == 'referer') {
        referer = v;
        keysToRemove.add(k);
      } else if (lowKey == 'origin') {
        origin = v;
        keysToRemove.add(k);
      } else if (lowKey == 'user-agent') {
        userAgent = v;
        keysToRemove.add(k);
      }
    });

    for (var k in keysToRemove) {
      headers.remove(k);
    }

    // 3. Re-inject with standard casing
    if (referer != null) {
      headers['Referer'] = referer!;
    }

    final bool isShowbox = url.contains('shegu.net');

    if (origin != null) {
      headers['Origin'] = origin!;
    }

    final finalUserAgent =
        userAgent ??
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36';

    headers['User-Agent'] = finalUserAgent;
    headers['user-agent'] = finalUserAgent;

    if (isShowbox) {
      headers['Accept'] = '*/*';
      headers['Connection'] = 'keep-alive';
      headers['Accept-Encoding'] = 'identity';
      headers['Accept-Language'] = 'en-US,en;q=0.9';
      headers['Sec-Fetch-Mode'] = 'cors';
      headers['Sec-Fetch-Site'] = 'cross-site';

      // X-Requested-With often helps bypass basic bot detection
      headers['X-Requested-With'] = 'XMLHttpRequest';

      // Manifests usually expect 'empty', segments expect 'video'
      headers['Sec-Fetch-Dest'] = url.contains('.ts') ? 'video' : 'empty';

      headers['Origin'] = 'https://www.febbox.com';
      headers['Referer'] = 'https://www.febbox.com/';

      // Strict Browser Client-Hints (Chrome 124)
      headers['sec-ch-ua'] =
          '"Chromium";v="124", "Not:A-Brand";v="8", "Google Chrome";v="124"';
      headers['sec-ch-ua-mobile'] = '?0';
      headers['sec-ch-ua-platform'] = '"Windows"';

      // Ensure the Final User-Agent is applied with the correct casing for CDN parsers
      headers['User-Agent'] = finalUserAgent;

      if (source.headers.containsKey('Cookie')) {
        headers['Cookie'] = source.headers['Cookie']!;
      }
    }

    return headers;
  }
}
