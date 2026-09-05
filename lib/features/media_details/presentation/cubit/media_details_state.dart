import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_credits.dart';
import '../../../home/domain/entities/movie.dart';

abstract class MediaDetailsState {}

class MediaDetailsInitial extends MediaDetailsState {}

class MediaDetailsLoading extends MediaDetailsState {}

class MediaDetailsLoaded extends MediaDetailsState {
  final MediaDetails details;
  final MediaCredits? credits;
  final List<Movie> recommendations;

  // TV specific
  final List<MediaEpisode> currentSeasonEpisodes;
  final int selectedSeasonNumber;
  final bool isEpisodesLoading;

  MediaDetailsLoaded({
    required this.details,
    this.credits,
    this.recommendations = const [],
    this.currentSeasonEpisodes = const [],
    this.selectedSeasonNumber = 1,
    this.isEpisodesLoading = false,
  });

  MediaDetailsLoaded copyWith({
    MediaDetails? details,
    MediaCredits? credits,
    List<Movie>? recommendations,
    List<MediaEpisode>? currentSeasonEpisodes,
    int? selectedSeasonNumber,
    bool? isEpisodesLoading,
  }) {
    return MediaDetailsLoaded(
      details: details ?? this.details,
      credits: credits ?? this.credits,
      recommendations: recommendations ?? this.recommendations,
      currentSeasonEpisodes:
          currentSeasonEpisodes ?? this.currentSeasonEpisodes,
      selectedSeasonNumber: selectedSeasonNumber ?? this.selectedSeasonNumber,
      isEpisodesLoading: isEpisodesLoading ?? this.isEpisodesLoading,
    );
  }
}

class MediaDetailsError extends MediaDetailsState {
  final String message;
  MediaDetailsError(this.message);
}

class MediaDetailsNoInternet extends MediaDetailsState {}
