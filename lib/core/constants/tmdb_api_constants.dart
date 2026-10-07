import 'package:aura_movies/core/config/env_config.dart';

class TmdbApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static String get bearerToken => EnvConfig.tmdbBearerToken;
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
