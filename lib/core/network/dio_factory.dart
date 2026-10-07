import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aura_movies/core/config/env_config.dart';
import 'package:aura_movies/core/constants/tmdb_api_constants.dart';
import 'api_exception.dart';

class DioFactory {
  /// Creates a Dio instance configured strictly for TMDB requests.
  static Dio createTmdbDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: TmdbApiConstants.baseUrl,
        headers: {
          'Authorization': 'Bearer ${EnvConfig.tmdbBearerToken}',
          'Content-Type': 'application/json',
        },
        receiveTimeout: TmdbApiConstants.receiveTimeout,
        connectTimeout: TmdbApiConstants.connectTimeout,
        sendTimeout: TmdbApiConstants.sendTimeout,
      ),
    );

    _addInterceptors(dio, debugLabel: 'TMDB-DIO');
    return dio;
  }

  /// Creates a Dio instance configured strictly for Scraper backend requests.
  static Dio createScraperDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.scraperBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    _addInterceptors(dio, debugLabel: 'SCRAPER-DIO');
    return dio;
  }

  /// Creates a generic Dio instance without default authorization or base URL.
  static Dio createGenericDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _addInterceptors(dio, debugLabel: 'GENERIC-DIO');
    return dio;
  }

  static void _addInterceptors(Dio dio, {required String debugLabel}) {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false, // Ensures Bearer token is NEVER logged
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (obj) => debugPrint('[$debugLabel] $obj'),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) {
          final apiException = ApiException.fromDioException(error);
          handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: apiException,
            ),
          );
        },
      ),
    );
  }
}
