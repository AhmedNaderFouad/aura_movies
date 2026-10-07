import 'package:dio/dio.dart';
import 'package:aura_movies/core/network/dio_factory.dart';

class MovieApiService {
  final Dio _dio;

  MovieApiService([Dio? dio]) : _dio = dio ?? DioFactory.createTmdbDio();

  Future<dynamic> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPopularTvShows({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/tv/popular',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUpcomingTvShows({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/tv/on_the_air',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTvShowDetails(int tvShowId) async {
    try {
      final response = await _dio.get('/tv/$tvShowId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTvShowSeasonDetails(int tvShowId, int seasonNumber) async {
    try {
      final response = await _dio.get('/tv/$tvShowId/season/$seasonNumber');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
