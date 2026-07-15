import '../entities/tv_show_details.dart';

abstract class TVShowDetailsRepository {
  Future<TVShowDetails> getTvShowDetails(int tvShowId);
  Future<List<Episode>> getSeasonEpisodes(int tvShowId, int seasonNumber);
}
