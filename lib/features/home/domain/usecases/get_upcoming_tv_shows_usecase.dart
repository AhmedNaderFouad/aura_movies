import '../entities/tv_show.dart';
import '../repositories/movie_repository.dart';

class GetUpcomingTvShowsUseCase {
  final MovieRepository repository;

  GetUpcomingTvShowsUseCase(this.repository);

  Future<List<TVShow>> call({int page = 1}) {
    return repository.getUpcomingTvShows(page: page);
  }
}
