import 'package:dio/dio.dart';
import 'package:aura_movies/core/constants/media_type.dart';

class MediaDetailsApiService {
  final Dio _dio;

  MediaDetailsApiService(this._dio);

  Future<dynamic> getMediaDetails(int id, MediaType type) async {
    final path = type == MediaType.movie ? '/movie/$id' : '/tv/$id';
    final response = await _dio.get(path);
    return response.data;
  }

  Future<dynamic> getMediaCredits(int id, MediaType type) async {
    final path = type == MediaType.movie
        ? '/movie/$id/credits'
        : '/tv/$id/credits';
    final response = await _dio.get(path);
    return response.data;
  }

  Future<dynamic> getMediaRecommendations(int id, MediaType type) async {
    final path = type == MediaType.movie
        ? '/movie/$id/recommendations'
        : '/tv/$id/recommendations';
    final response = await _dio.get(path);
    return response.data;
  }

  Future<dynamic> getTvSeasonDetails(int tvShowId, int seasonNumber) async {
    final response = await _dio.get('/tv/$tvShowId/season/$seasonNumber');
    return response.data;
  }
}
