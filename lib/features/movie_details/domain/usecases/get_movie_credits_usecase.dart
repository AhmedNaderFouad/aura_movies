import '../entities/movie_credits.dart';
import '../repositories/movie_details_repository.dart';

class GetMovieCreditsUseCase {
  final MovieDetailsRepository repository;

  GetMovieCreditsUseCase(this.repository);

  Future<MovieCreditsEntity> call(int movieId) async {
    return repository.getMovieCredits(movieId);
  }
}

