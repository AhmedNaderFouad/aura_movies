import '../repositories/watchlist_repository.dart';

class RemoveFromWatchlistUseCase {
  final WatchlistRepository repository;

  RemoveFromWatchlistUseCase(this.repository);

  Future<void> call(int movieId) async {
    return await repository.removeFromWatchlist(movieId);
  }
}
