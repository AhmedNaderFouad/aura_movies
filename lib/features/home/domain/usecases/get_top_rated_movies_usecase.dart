import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetTopRatedMoviesUseCase {
  final MovieRepository repository;

  GetTopRatedMoviesUseCase(this.repository);

  Future<List<Movie>> call({int page = 1}) async {
    return await repository.getTopRatedMovies(page: page);
  }
}
