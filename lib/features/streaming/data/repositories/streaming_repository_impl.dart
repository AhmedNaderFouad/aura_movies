import 'package:dio/dio.dart';
import '../../../../core/models/video_source_model.dart';
import '../../../../core/services/streaming_providers/vaplayer_provider.dart';
import '../../../../core/services/streaming_providers/vidlink_provider.dart';
import '../../../../core/services/streaming_providers/showbox_provider.dart';
import '../../../../core/services/streaming_providers/netmirror_provider.dart';
import '../../../../core/services/streaming_providers/onetouchtv_provider.dart';
import '../../domain/repositories/streaming_repository.dart';

class StreamingRepositoryImpl implements StreamingRepository {
  final VaPlayerProvider _vaPlayerProvider;
  final VidLinkProvider _vidLinkProvider;
  final ShowboxProvider _showboxProvider;
  final NetMirrorProvider _netMirrorProvider;
  final OneTouchTVProvider _oneTouchTVProvider;

  StreamingRepositoryImpl({
    VaPlayerProvider? vaPlayerProvider,
    VidLinkProvider? vidLinkProvider,
    ShowboxProvider? showboxProvider,
    NetMirrorProvider? netMirrorProvider,
    OneTouchTVProvider? oneTouchTVProvider,
  })  : _vaPlayerProvider = vaPlayerProvider ?? VaPlayerProvider(),
        _vidLinkProvider = vidLinkProvider ?? VidLinkProvider(),
        _showboxProvider = showboxProvider ?? ShowboxProvider(),
        _netMirrorProvider = netMirrorProvider ?? NetMirrorProvider(),
        _oneTouchTVProvider = oneTouchTVProvider ?? OneTouchTVProvider();

  @override
  Future<List<VideoSource>> getStreams({
    required String providerId,
    required String tmdbId,
    required String type,
    int? season,
    int? episode,
    String? originalLanguage,
    CancelToken? cancelToken,
  }) async {
    switch (providerId) {
      case 'vaplayer':
        return await _vaPlayerProvider.fetchStreams(
          tmdbId: tmdbId,
          type: type,
          season: season,
          episode: episode,
          originalLanguage: originalLanguage,
          cancelToken: cancelToken,
        );
      case 'vidlink':
        return await _vidLinkProvider.fetchStreams(
          tmdbId: tmdbId,
          type: type,
          season: season,
          episode: episode,
          originalLanguage: originalLanguage,
          cancelToken: cancelToken,
        );
      case 'showbox':
        return await _showboxProvider.fetchStreams(
          tmdbId: tmdbId,
          type: type,
          season: season,
          episode: episode,
          originalLanguage: originalLanguage,
          cancelToken: cancelToken,
        );
      case 'netmirror':
        return await _netMirrorProvider.fetchStreams(
          tmdbId: tmdbId,
          type: type,
          season: season,
          episode: episode,
          originalLanguage: originalLanguage,
          cancelToken: cancelToken,
        );
      case 'onetouchtv':
        return await _oneTouchTVProvider.fetchStreams(
          tmdbId: tmdbId,
          type: type,
          season: season,
          episode: episode,
          originalLanguage: originalLanguage,
          cancelToken: cancelToken,
        );
      default:
        return [];
    }
  }
}
