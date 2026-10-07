import 'package:dio/dio.dart';
import '../../../../core/models/video_source_model.dart';
import '../repositories/streaming_repository.dart';

class GetStreamingSourcesUseCase {
  final StreamingRepository _repository;

  GetStreamingSourcesUseCase(this._repository);

  Future<List<VideoSource>> call({
    required String providerId,
    required String tmdbId,
    required String type,
    int? season,
    int? episode,
    String? originalLanguage,
    CancelToken? cancelToken,
  }) {
    return _repository.getStreams(
      providerId: providerId,
      tmdbId: tmdbId,
      type: type,
      season: season,
      episode: episode,
      originalLanguage: originalLanguage,
      cancelToken: cancelToken,
    );
  }
}
