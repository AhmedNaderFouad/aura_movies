import 'package:aura_movies/core/constants/media_type.dart';
import '../entities/media_details.dart';
import '../repositories/media_details_repository.dart';

class GetMediaDetailsUseCase {
  final MediaDetailsRepository repository;

  GetMediaDetailsUseCase(this.repository);

  Future<MediaDetails> execute(int id, MediaType type) {
    return repository.getMediaDetails(id, type);
  }
}
