import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/video_source_model.dart';
import '../../domain/repositories/subtitle_repository.dart';

part 'subtitle_state.dart';

class SubtitleCubit extends Cubit<SubtitleState> {
  final SubtitleRepository _repository;

  SubtitleCubit(this._repository) : super(const SubtitleState());

  Future<void> fetchSubtitles({
    required String tmdbId,
    String? imdbId,
    bool isTv = false,
    int? season,
    int? episode,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        wyzieSubtitles: [],
        openSubtitles: [],
        selectedSubtitle: () => null,
      ),
    );

    try {
      final results = await Future.wait([
        _repository.getWyzieSubtitles(
          tmdbId: tmdbId,
          imdbId: imdbId,
          isTv: isTv,
          season: season,
          episode: episode,
        ),
        _repository.getOpenSubtitles(
          tmdbId: tmdbId,
          imdbId: imdbId,
          isTv: isTv,
          season: season,
          episode: episode,
        ),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          wyzieSubtitles: results[0],
          openSubtitles: results[1],
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void selectSubtitle(SubtitleModel? subtitle) {
    emit(state.copyWith(selectedSubtitle: () => subtitle));
  }

  Future<String?> getOpenSubtitlesUrl(String fileId) async {
    return _repository.getDownloadUrl(fileId);
  }
}
