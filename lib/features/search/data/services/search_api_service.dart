import 'package:dio/dio.dart';
import 'package:aura_movies/core/network/dio_factory.dart';

class SearchApiService {
  final Dio _dio;

  SearchApiService([Dio? dio]) : _dio = dio ?? DioFactory.createTmdbDio();

  Future<dynamic> multiSearch({required String query, int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {'query': query, 'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> discoverMovies({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'primary_release_date.desc',
    int? companyId,
    String? watchProviderIds,
    String? watchRegion = 'US',
    String? watchMonetizationType = 'flatrate',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'language': 'en-US',
        'sort_by': sortBy,
        'include_adult': false,
        'include_video': false,
        'with_genres': genreId,
        'with_original_language': language,
        'primary_release_year': year,
        'with_companies': companyId,
        'with_watch_providers': watchProviderIds,
        'watch_region': watchProviderIds != null ? watchRegion : null,
        'with_watch_monetization_types': watchProviderIds != null
            ? watchMonetizationType
            : null,
      };
      params.removeWhere((key, value) => value == null);

      final response = await _dio.get(
        '/discover/movie',
        queryParameters: params,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> discoverTvShows({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'first_air_date.desc',
    int? networkId,
    int? companyId,
    String? watchProviderIds,
    String? watchRegion = 'US',
    String? watchMonetizationType = 'flatrate',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'language': 'en-US',
        'sort_by': sortBy,
        'include_adult': false,
        'with_genres': genreId,
        'with_original_language': language,
        'first_air_date_year': year,
        'with_networks': networkId,
        'with_companies': companyId,
        'with_watch_providers': watchProviderIds,
        'watch_region': watchProviderIds != null ? watchRegion : null,
        'with_watch_monetization_types': watchProviderIds != null
            ? watchMonetizationType
            : null,
      };
      params.removeWhere((key, value) => value == null);

      final response = await _dio.get('/discover/tv', queryParameters: params);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
