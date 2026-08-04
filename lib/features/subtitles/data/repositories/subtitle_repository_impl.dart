import '../../domain/repositories/subtitle_repository.dart';
import '../../../../core/models/video_source_model.dart';
import '../../../../core/services/subtitle_service.dart';
import '../../../../core/services/open_subtitles_service.dart';

class SubtitleRepositoryImpl implements SubtitleRepository {
  final SubtitleService _wyzieService;
  final OpenSubtitlesService _openSubtitlesService;

  SubtitleRepositoryImpl({
    required SubtitleService wyzieService,
    required OpenSubtitlesService openSubtitlesService,
  }) : _wyzieService = wyzieService,
       _openSubtitlesService = openSubtitlesService;

  @override
  Future<List<SubtitleModel>> getWyzieSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
  }) {
    return _wyzieService.fetchSubtitles(
      tmdbId: tmdbId,
      imdbId: imdbId,
      isTv: isTv,
      season: season,
      episode: episode,
    );
  }

  @override
  Future<List<SubtitleModel>> getOpenSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
  }) {
    return _openSubtitlesService.searchSubtitles(
      tmdbId: tmdbId,
      imdbId: imdbId,
      isTv: isTv,
      season: season,
      episode: episode,
    );
  }

  @override
  Future<String?> getDownloadUrl(String fileId) {
    return _openSubtitlesService.getDownloadUrl(fileId);
  }
}
