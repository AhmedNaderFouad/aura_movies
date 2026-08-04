import '../../../home/data/services/movie_api_service.dart';
import '../../domain/entities/tv_show_details.dart';
import '../../domain/repositories/tv_show_details_repository.dart';
import '../models/tv_show_details_model.dart';

class TVShowDetailsRepositoryImpl implements TVShowDetailsRepository {
  final MovieApiService apiService;

  TVShowDetailsRepositoryImpl({required this.apiService});

  @override
  Future<TVShowDetails> getTvShowDetails(int tvShowId) async {
    final data = await apiService.getTvShowDetails(tvShowId);
    return TVShowDetailsModel.fromJson(data);
  }

  @override
  Future<List<Episode>> getSeasonEpisodes(
    int tvShowId,
    int seasonNumber,
  ) async {
    final data = await apiService.getTvShowSeasonDetails(
      tvShowId,
      seasonNumber,
    );
    final episodesJson = data['episodes'] as List? ?? [];
    return episodesJson.map((e) => EpisodeModel.fromJson(e)).toList();
  }
}
