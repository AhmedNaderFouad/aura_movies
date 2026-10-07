import 'package:dio/dio.dart';
import '../../../../core/models/video_source_model.dart';

abstract class StreamingRepository {
  Future<List<VideoSource>> getStreams({
    required String providerId,
    required String tmdbId,
    required String type,
    int? season,
    int? episode,
    String? originalLanguage,
    CancelToken? cancelToken,
  });
}
