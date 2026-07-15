import '../../../home/data/models/movie_model.dart';
import '../../../home/domain/entities/movie.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addToWatchlist(Movie movie) async {
    final movieModel = MovieModel(
      id: movie.id,
      title: movie.title,
      backdropPath: movie.backdropPath,
      posterPath: movie.posterPath,
      overview: movie.overview,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
      isTvShow: movie.isTvShow,
    );
    return localDataSource.addToWatchlist(movieModel);
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    return localDataSource.removeFromWatchlist(movieId);
  }

  @override
  Future<List<Movie>> getWatchlist() async {
    return localDataSource.getWatchlist();
  }

  @override
  Future<bool> isInWatchlist(int movieId) async {
    return localDataSource.isInWatchlist(movieId);
  }
}
