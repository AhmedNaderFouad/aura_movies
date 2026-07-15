import '../entities/tv_show.dart';
import '../repositories/movie_repository.dart';

class GetPopularTvShowsUseCase {
  final MovieRepository repository;

  GetPopularTvShowsUseCase(this.repository);

  Future<List<TVShow>> call({int page = 1}) {
    return repository.getPopularTvShows(page: page);
  }
}
