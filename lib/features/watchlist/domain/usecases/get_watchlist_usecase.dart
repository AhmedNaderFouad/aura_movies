import '../../../home/domain/entities/movie.dart';
import '../repositories/watchlist_repository.dart';

class GetWatchlistUseCase {
  final WatchlistRepository repository;

  GetWatchlistUseCase(this.repository);

  Future<List<Movie>> call() async {
    return await repository.getWatchlist();
  }
}
