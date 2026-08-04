import '../entities/movie.dart';
import '../entities/tv_show.dart';

abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies({int page = 1});

  Future<List<Movie>> getTopRatedMovies({int page = 1});

  Future<List<Movie>> getUpcomingMovies({int page = 1});

  Future<List<Movie>> getNowPlayingMovies({int page = 1});

  Future<List<TVShow>> getPopularTvShows({int page = 1});

  Future<List<TVShow>> getUpcomingTvShows({int page = 1});
}
