import 'package:dio/dio.dart';

class SearchApiService {
  late final Dio _dio;

  SearchApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTk0ZGQzZGI3YjJmYmRjODdjZmMyMGNiZGEzYjBkMiIsIm5iZiI6MTc3Nzk5Mjg1NC42Niwic3ViIjoiNjlmYTA0OTYwM2MyZTMwNjA1ZGFhZGQ0Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.96PELO8smmCnMik2dZjn2DRaM2Z6Edw4LkcO9Ut4soM',
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

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
    String sortBy = 'popularity.desc',
    int? companyId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'sort_by': sortBy,
        'with_genres': genreId,
        'with_original_language': language,
        'primary_release_year': year,
        'with_companies': companyId,
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
    String sortBy = 'popularity.desc',
    int? networkId,
    int? companyId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'sort_by': sortBy,
        'with_genres': genreId,
        'with_original_language': language,
        'first_air_date_year': year,
        'with_networks': networkId,
        'with_companies': companyId,
      };
      params.removeWhere((key, value) => value == null);

      final response = await _dio.get('/discover/tv', queryParameters: params);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
