import 'package:aura_movies/core/constants/media_type.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_credits.dart';
import '../../../home/domain/entities/movie.dart';
import '../../../home/data/models/movie_model.dart';
import '../../domain/repositories/media_details_repository.dart';
import '../models/media_details_model.dart';
import '../models/media_credits_model.dart';
import '../services/media_details_api_service.dart';

class MediaDetailsRepositoryImpl implements MediaDetailsRepository {
  final MediaDetailsApiService apiService;

  MediaDetailsRepositoryImpl({required this.apiService});

  @override
  Future<MediaDetails> getMediaDetails(int id, MediaType type) async {
    final data = await apiService.getMediaDetails(id, type);
    return MediaDetailsModel.fromJson(data, type);
  }

  @override
  Future<MediaCredits> getMediaCredits(int id, MediaType type) async {
    final data = await apiService.getMediaCredits(id, type);
    return MediaCreditsModel.fromJson(data);
  }

  @override
  Future<List<Movie>> getMediaRecommendations(int id, MediaType type) async {
    final data = await apiService.getMediaRecommendations(id, type);
    final List results = data['results'] ?? [];
    return results.map((m) => MovieModel.fromJson(m)).toList();
  }

  @override
  Future<List<MediaEpisode>> getTvSeasonEpisodes(
    int tvShowId,
    int seasonNumber,
  ) async {
    final data = await apiService.getTvSeasonDetails(tvShowId, seasonNumber);
    final List episodesJson = data['episodes'] ?? [];
    return episodesJson.map((e) => MediaEpisodeModel.fromJson(e)).toList();
  }
}
