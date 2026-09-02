import '../repositories/movie_details_repository.dart';
import '../../../home/domain/entities/movie.dart';

class GetMovieRecommendationsUseCase {
  final MovieDetailsRepository repository;

  GetMovieRecommendationsUseCase(this.repository);

  Future<List<Movie>> call(int movieId) async {
    return await repository.getMovieRecommendations(movieId);
  }
}
