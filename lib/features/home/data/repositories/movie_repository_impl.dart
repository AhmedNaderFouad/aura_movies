import '../../domain/entities/movie.dart';
import '../../domain/entities/tv_show.dart';
import '../../domain/repositories/movie_repository.dart';
import '../models/movie_response_model.dart';
import '../models/tv_show_response_model.dart';
import '../services/movie_api_service.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieApiService apiService;

  MovieRepositoryImpl({required this.apiService});

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final data = await apiService.getPopularMovies(page: page);
      final response = MovieResponseModel.fromJson(data);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final data = await apiService.getTopRatedMovies(page: page);
      final response = MovieResponseModel.fromJson(data);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    try {
      final data = await apiService.getUpcomingMovies(page: page);
      final response = MovieResponseModel.fromJson(data);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    try {
      final data = await apiService.getNowPlayingMovies(page: page);
      final response = MovieResponseModel.fromJson(data);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TVShow>> getPopularTvShows({int page = 1}) async {
    try {
      final data = await apiService.getPopularTvShows(page: page);
      final response = TVShowResponseModel.fromJson(data);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TVShow>> getUpcomingTvShows({int page = 1}) async {
    try {
      final data = await apiService.getUpcomingTvShows(page: page);
      final response = TVShowResponseModel.fromJson(data);
      return response.results;
    } catch (e) {
      rethrow;
    }
  }
}
