part of 'movie_details_cubit.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {
  const MovieDetailsInitial();
}

class MovieDetailsLoading extends MovieDetailsState {
  const MovieDetailsLoading();
}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieDetails movieDetails;
  final MovieCreditsEntity? credits;
  final List<Movie> recommendations;

  const MovieDetailsLoaded(
    this.movieDetails, {
    this.credits,
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [movieDetails, credits, recommendations];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  const MovieDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MovieDetailsNoInternet extends MovieDetailsState {
  const MovieDetailsNoInternet();
}
