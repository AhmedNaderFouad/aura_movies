import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetUpcomingMoviesUseCase {
  final MovieRepository repository;

  GetUpcomingMoviesUseCase(this.repository);

  Future<List<Movie>> call({int page = 1}) async {
    return await repository.getUpcomingMovies(page: page);
  }
}
