import '../entities/movie_details.dart';
import '../entities/movie_credits.dart';

abstract class MovieDetailsRepository {
  Future<MovieDetails> getMovieDetails(int movieId);
  Future<MovieCreditsEntity> getMovieCredits(int movieId);
}
