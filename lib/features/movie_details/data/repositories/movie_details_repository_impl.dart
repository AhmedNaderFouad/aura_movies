import '../../domain/entities/movie_details.dart';
import '../../domain/entities/movie_credits.dart';
import '../../domain/repositories/movie_details_repository.dart';
import '../models/movie_details_model.dart';
import '../models/movie_credits_model.dart';
import '../services/movie_details_api_service.dart';

class MovieDetailsRepositoryImpl implements MovieDetailsRepository {
  final MovieDetailsApiService apiService;

  MovieDetailsRepositoryImpl({required this.apiService});

  @override
  Future<MovieDetails> getMovieDetails(int movieId) async {
    try {
      final data = await apiService.getMovieDetails(movieId);
      final movieDetailsModel = MovieDetailsModel.fromJson(data);
      return movieDetailsModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieCreditsEntity> getMovieCredits(int movieId) async {
    try {
      final data = await apiService.getMovieCredits(movieId);
      final creditsModel = MovieCredits.fromJson(data);
      return MovieCreditsEntity(
        cast: creditsModel.cast
            .map((c) => CastMemberEntity(
                  id: c.id,
                  name: c.name,
                  character: c.character,
                  profilePath: c.profilePath,
                  order: c.order,
                ))
            .toList(),
        crew: creditsModel.crew
            .map((c) => CrewMemberEntity(
                  id: c.id,
                  name: c.name,
                  job: c.job,
                  department: c.department,
                  profilePath: c.profilePath,
                ))
            .toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}


