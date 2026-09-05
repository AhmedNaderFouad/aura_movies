import 'package:aura_movies/core/constants/media_type.dart';
import '../entities/media_details.dart';
import '../entities/media_credits.dart';
import '../../../home/domain/entities/movie.dart';

abstract class MediaDetailsRepository {
  Future<MediaDetails> getMediaDetails(int id, MediaType type);
  Future<MediaCredits> getMediaCredits(int id, MediaType type);
  Future<List<Movie>> getMediaRecommendations(int id, MediaType type);
  Future<List<MediaEpisode>> getTvSeasonEpisodes(
    int tvShowId,
    int seasonNumber,
  );
}
