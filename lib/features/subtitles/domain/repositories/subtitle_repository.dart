import '../../data/models/subtitle_model.dart';

abstract class SubtitleRepository {
  Future<List<SubtitleModel>> getWyzieSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
  });

  Future<List<SubtitleModel>> getOpenSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
  });

  Future<String?> getDownloadUrl(String fileId);
}
