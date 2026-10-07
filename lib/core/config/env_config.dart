import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get tmdbBearerToken {
    final token = dotenv.env['TMDB_BEARER_TOKEN'];
    if (token == null || token.isEmpty) {
      throw StateError('TMDB_BEARER_TOKEN is missing in .env');
    }
    return token;
  }

  static String get openSubtitlesApiKey {
    final key = dotenv.env['OPENSUBTITLES_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('OPENSUBTITLES_API_KEY is missing in .env');
    }
    return key;
  }

  static String get wyzieApiKey {
    final key = dotenv.env['WYZIE_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('WYZIE_API_KEY is missing in .env');
    }
    return key;
  }

  static String get scraperBaseUrl {
    return dotenv.env['SCRAPER_BASE_URL'] ??
        'https://aura-movies-scraper.vercel.app';
  }
}
