import '../../../home/domain/entities/movie.dart';

abstract class WatchlistRepository {
  Future<void> addToWatchlist(Movie movie);
  Future<void> removeFromWatchlist(int movieId);
  Future<List<Movie>> getWatchlist();
  Future<bool> isInWatchlist(int movieId);
}
