import '../../../home/domain/entities/movie.dart';
import '../repositories/watchlist_repository.dart';

class AddToWatchlistUseCase {
  final WatchlistRepository repository;

  AddToWatchlistUseCase(this.repository);

  Future<void> call(Movie movie) async {
    return await repository.addToWatchlist(movie);
  }
}
