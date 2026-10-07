import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_streaming_sources_usecase.dart';
import 'server_selection_state.dart';

class ServerSelectionCubit extends Cubit<ServerSelectionState> {
  final GetStreamingSourcesUseCase _getStreamingSourcesUseCase;

  ServerSelectionCubit(this._getStreamingSourcesUseCase)
      : super(const ServerSelectionInitial());

  Future<void> selectServer({
    required String providerId,
    required String tmdbId,
    required String type,
    int? season,
    int? episode,
    String? originalLanguage,
    CancelToken? cancelToken,
  }) async {
    if (state is ServerSelectionLoading) return;

    emit(ServerSelectionLoading(providerId));

    try {
      final sources = await _getStreamingSourcesUseCase(
        providerId: providerId,
        tmdbId: tmdbId,
        type: type,
        season: season,
        episode: episode,
        originalLanguage: originalLanguage,
        cancelToken: cancelToken,
      );

      if (sources.isNotEmpty) {
        emit(ServerSelectionSuccess(sources.first));
      } else {
        emit(const ServerSelectionEmpty());
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        emit(const ServerSelectionInitial());
        return;
      }
      debugPrint('ServerSelectionCubit Error: $e');
      emit(ServerSelectionError(e.toString()));
    }
  }

  void reset() {
    emit(const ServerSelectionInitial());
  }
}
