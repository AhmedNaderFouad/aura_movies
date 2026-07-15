part of 'home_cubit.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  final List<Movie> trendingMovies;
  final List<Movie> topRatedMovies;
  final List<Movie> upcomingMovies;
  final List<TVShow> trendingTvShows;
  final List<TVShow> upcomingTvShows;

  const HomeSuccess({
    required this.trendingMovies,
    required this.topRatedMovies,
    required this.upcomingMovies,
    required this.trendingTvShows,
    required this.upcomingTvShows,
  });
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});
}

class HomeNoInternet extends HomeState {
  const HomeNoInternet();
}
