import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/tv_show_details_repository.dart';
import 'tv_show_details_state.dart';

class TVShowDetailsCubit extends Cubit<TVShowDetailsState> {
  final TVShowDetailsRepository repository;

  TVShowDetailsCubit({required this.repository})
    : super(TVShowDetailsInitial());

  Future<void> loadTVShowDetails(int tvShowId) async {
    emit(TVShowDetailsLoading());
    try {
      final details = await repository.getTvShowDetails(tvShowId);

      // Load first season by default if available
      int initialSeason = 1;
      if (details.seasons.isNotEmpty) {
        // Find the first season number (often it starts at 1, but sometimes 0 for specials)
        // We'll prefer season 1 if it exists, otherwise the first in the list.
        final hasSeasonOne = details.seasons.any((s) => s.seasonNumber == 1);
        initialSeason = hasSeasonOne ? 1 : details.seasons.first.seasonNumber;
      }

      final episodes = await repository.getSeasonEpisodes(
        tvShowId,
        initialSeason,
      );

      emit(
        TVShowDetailsLoaded(
          details: details,
          currentSeasonEpisodes: episodes,
          selectedSeasonNumber: initialSeason,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(TVShowDetailsNoInternet());
      } else {
        emit(TVShowDetailsError(e.toString()));
      }
    } catch (e) {
      emit(TVShowDetailsError(e.toString()));
    }
  }

  Future<void> changeSeason(int seasonNumber) async {
    final currentState = state;
    if (currentState is TVShowDetailsLoaded) {
      emit(
        currentState.copyWith(
          isEpisodesLoading: true,
          selectedSeasonNumber: seasonNumber,
        ),
      );
      try {
        final episodes = await repository.getSeasonEpisodes(
          currentState.details.id,
          seasonNumber,
        );
        emit(
          currentState.copyWith(
            currentSeasonEpisodes: episodes,
            selectedSeasonNumber: seasonNumber,
            isEpisodesLoading: false,
          ),
        );
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          emit(TVShowDetailsNoInternet());
        } else {
          emit(TVShowDetailsError(e.toString()));
        }
      } catch (e) {
        emit(TVShowDetailsError(e.toString()));
      }
    }
  }
}
