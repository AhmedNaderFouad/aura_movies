import 'package:aura_movies/core/constants/media_type.dart';
import '../entities/media_credits.dart';
import '../repositories/media_details_repository.dart';

class GetMediaCreditsUseCase {
  final MediaDetailsRepository repository;

  GetMediaCreditsUseCase(this.repository);

  Future<MediaCredits> execute(int id, MediaType type) {
    return repository.getMediaCredits(id, type);
  }
}
