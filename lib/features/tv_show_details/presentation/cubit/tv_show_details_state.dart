import '../../domain/entities/tv_show_details.dart';

abstract class TVShowDetailsState {}

class TVShowDetailsInitial extends TVShowDetailsState {}

class TVShowDetailsLoading extends TVShowDetailsState {}

class TVShowDetailsLoaded extends TVShowDetailsState {
  final TVShowDetails details;
  final List<Episode> currentSeasonEpisodes;
  final int selectedSeasonNumber;
  final bool isEpisodesLoading;

  TVShowDetailsLoaded({
    required this.details,
    required this.currentSeasonEpisodes,
    required this.selectedSeasonNumber,
    this.isEpisodesLoading = false,
  });

  TVShowDetailsLoaded copyWith({
    TVShowDetails? details,
    List<Episode>? currentSeasonEpisodes,
    int? selectedSeasonNumber,
    bool? isEpisodesLoading,
  }) {
    return TVShowDetailsLoaded(
      details: details ?? this.details,
      currentSeasonEpisodes: currentSeasonEpisodes ?? this.currentSeasonEpisodes,
      selectedSeasonNumber: selectedSeasonNumber ?? this.selectedSeasonNumber,
      isEpisodesLoading: isEpisodesLoading ?? this.isEpisodesLoading,
    );
  }
}

class TVShowDetailsError extends TVShowDetailsState {
  final String message;
  TVShowDetailsError(this.message);
}

class TVShowDetailsNoInternet extends TVShowDetailsState {}
