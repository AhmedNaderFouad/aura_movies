import 'package:aura_movies/core/constants/media_type.dart';
import '../../../home/domain/entities/movie.dart';
import '../repositories/media_details_repository.dart';

class GetMediaRecommendationsUseCase {
  final MediaDetailsRepository repository;

  GetMediaRecommendationsUseCase(this.repository);

  Future<List<Movie>> execute(int id, MediaType type) {
    return repository.getMediaRecommendations(id, type);
  }
}
