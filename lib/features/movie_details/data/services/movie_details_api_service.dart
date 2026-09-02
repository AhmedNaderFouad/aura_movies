import 'package:dio/dio.dart';

class MovieDetailsApiService {
  late final Dio _dio;

  MovieDetailsApiService(Dio dio) {
    _dio = dio;
  }

  Future<dynamic> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMovieCredits(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/credits');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMovieRecommendations(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/recommendations');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
