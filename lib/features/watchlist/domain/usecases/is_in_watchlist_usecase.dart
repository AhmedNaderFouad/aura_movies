import '../repositories/watchlist_repository.dart';

class IsInWatchlistUseCase {
  final WatchlistRepository repository;

  IsInWatchlistUseCase(this.repository);

  Future<bool> call(int movieId) async {
    return await repository.isInWatchlist(movieId);
  }
}
