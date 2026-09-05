import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:aura_movies/core/constants/media_type.dart';
import '../../domain/repositories/media_details_repository.dart';
import '../../domain/usecases/get_media_details_usecase.dart';
import '../../domain/usecases/get_media_credits_usecase.dart';
import '../../domain/usecases/get_media_recommendations_usecase.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_credits.dart';
import '../../../home/domain/entities/movie.dart';
import 'media_details_state.dart';

class MediaDetailsCubit extends Cubit<MediaDetailsState> {
  final GetMediaDetailsUseCase getMediaDetailsUseCase;
  final GetMediaCreditsUseCase getMediaCreditsUseCase;
  final GetMediaRecommendationsUseCase getMediaRecommendationsUseCase;
  final MediaDetailsRepository repository;

  MediaDetailsCubit({
    required this.getMediaDetailsUseCase,
    required this.getMediaCreditsUseCase,
    required this.getMediaRecommendationsUseCase,
    required this.repository,
  }) : super(MediaDetailsInitial());

  Future<void> loadMediaDetails(int id, MediaType type) async {
    emit(MediaDetailsLoading());
    try {
      final results = await Future.wait([
        getMediaDetailsUseCase.execute(id, type),
        getMediaCreditsUseCase.execute(id, type),
        getMediaRecommendationsUseCase.execute(id, type),
      ]);

      final details = results[0] as MediaDetails;
      final credits = results[1] as MediaCredits;
      final recommendations = results[2] as List<Movie>;

      if (type == MediaType.tv) {
        int initialSeason = 1;
        if (details.seasons.isNotEmpty) {
          final hasSeasonOne = details.seasons.any((s) => s.seasonNumber == 1);
          initialSeason = hasSeasonOne ? 1 : details.seasons.first.seasonNumber;
        }

        final episodes = await repository.getTvSeasonEpisodes(
          id,
          initialSeason,
        );

        emit(
          MediaDetailsLoaded(
            details: details,
            credits: credits,
            recommendations: recommendations,
            currentSeasonEpisodes: episodes,
            selectedSeasonNumber: initialSeason,
          ),
        );
      } else {
        emit(
          MediaDetailsLoaded(
            details: details,
            credits: credits,
            recommendations: recommendations,
          ),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(MediaDetailsNoInternet());
      } else {
        emit(MediaDetailsError(e.toString()));
      }
    } catch (e) {
      emit(MediaDetailsError(e.toString()));
    }
  }

  Future<void> changeSeason(int seasonNumber) async {
    final currentState = state;
    if (currentState is MediaDetailsLoaded &&
        currentState.details.mediaType == MediaType.tv) {
      emit(
        currentState.copyWith(
          isEpisodesLoading: true,
          selectedSeasonNumber: seasonNumber,
        ),
      );
      try {
        final episodes = await repository.getTvSeasonEpisodes(
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
          emit(MediaDetailsNoInternet());
        } else {
          emit(MediaDetailsError(e.toString()));
        }
      } catch (e) {
        emit(MediaDetailsError(e.toString()));
      }
    }
  }
}
