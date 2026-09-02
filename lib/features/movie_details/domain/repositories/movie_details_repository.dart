import '../entities/movie_details.dart';
import '../entities/movie_credits.dart';
import '../../../home/domain/entities/movie.dart';

abstract class MovieDetailsRepository {
  Future<MovieDetails> getMovieDetails(int movieId);
  Future<MovieCreditsEntity> getMovieCredits(int movieId);
  Future<List<Movie>> getMovieRecommendations(int movieId);
}
