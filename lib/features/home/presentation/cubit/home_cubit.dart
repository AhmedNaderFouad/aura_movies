import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../domain/entities/movie.dart';
import '../../domain/entities/tv_show.dart';
import '../../domain/usecases/get_popular_movies_usecase.dart';
import '../../domain/usecases/get_top_rated_movies_usecase.dart';
import '../../domain/usecases/get_upcoming_movies_usecase.dart';
import '../../domain/usecases/get_upcoming_tv_shows_usecase.dart';
import '../../domain/usecases/get_popular_tv_shows_usecase.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetPopularMoviesUseCase getPopularMoviesUseCase;
  final GetTopRatedMoviesUseCase getTopRatedMoviesUseCase;
  final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;
  final GetUpcomingTvShowsUseCase getUpcomingTvShowsUseCase;
  final GetPopularTvShowsUseCase getPopularTvShowsUseCase;

  HomeCubit({
    required this.getPopularMoviesUseCase,
    required this.getTopRatedMoviesUseCase,
    required this.getUpcomingMoviesUseCase,
    required this.getUpcomingTvShowsUseCase,
    required this.getPopularTvShowsUseCase,
  }) : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    try {
      final trendingMovies = await getPopularMoviesUseCase.call();
      final topRatedMovies = await getTopRatedMoviesUseCase.call();
      final upcomingMoviesRaw = await getUpcomingMoviesUseCase.call();
      final trendingTvShows = await getPopularTvShowsUseCase.call();
      final upcomingTvShowsRaw = await getUpcomingTvShowsUseCase.call();

      // Filter and sort upcoming movies (closest first)
      final upcomingMovies = _filterAndSortByDate(
        upcomingMoviesRaw,
        (movie) => movie.releaseDate,
      ).cast<Movie>();

      // Filter and sort upcoming TV shows (closest first)
      final upcomingTvShows = _filterAndSortByDate(
        upcomingTvShowsRaw,
        (tvShow) => tvShow.firstAirDate,
      ).cast<TVShow>();

      emit(HomeSuccess(
        trendingMovies: trendingMovies,
        topRatedMovies: topRatedMovies,
        upcomingMovies: upcomingMovies,
        trendingTvShows: trendingTvShows,
        upcomingTvShows: upcomingTvShows,
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(const HomeNoInternet());
      } else {
        emit(HomeError(message: e.toString()));
      }
    } on SocketException {
      emit(const HomeNoInternet());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Filter media by future date and sort by closest date first
  List<dynamic> _filterAndSortByDate(
    List<dynamic> items,
    String? Function(dynamic) getDateString,
  ) {
    final now = DateTime.now();

    final filtered = items.where((item) {
      final dateStr = getDateString(item);
      if (dateStr == null || dateStr.isEmpty) return false;

      try {
        final date = DateTime.parse(dateStr);
        return date.isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();

    // Sort by date ascending (closest first)
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(getDateString(a)!);
        final dateB = DateTime.parse(getDateString(b)!);
        return dateA.compareTo(dateB);
      } catch (_) {
        return 0;
      }
    });

    return filtered;
  }
}

