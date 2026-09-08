import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/models/media.dart';
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

      // Combine all upcoming releases and filter out any remaining items without posters
      var upcomingReleases = [...upcomingMovies, ...upcomingTvShows];

      // Double-check: filter out any items that still don't have posters (defensive)
      upcomingReleases = upcomingReleases.where((item) {
        return item.posterPath != null && item.posterPath!.isNotEmpty;
      }).toList();

      // Deduplicate: remove duplicate items (same ID that appear in both lists)
      final seenIds = <int>{};
      upcomingReleases = upcomingReleases.where((item) {
        if (seenIds.contains(item.id)) {
          return false; // Skip duplicates
        }
        seenIds.add(item.id);
        return true;
      }).toList();

      upcomingReleases.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.releaseDate!);
          final dateB = DateTime.parse(b.releaseDate!);
          return dateA.compareTo(dateB);
        } catch (_) {
          return 0;
        }
      });

      emit(
        HomeSuccess(
          trendingMovies: trendingMovies,
          topRatedMovies: topRatedMovies,
          upcomingMovies: upcomingMovies,
          trendingTvShows: trendingTvShows,
          upcomingTvShows: upcomingTvShows,
          upcomingReleases: upcomingReleases,
        ),
      );
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

  /// Filter media by future date and sort by closest date first.
  /// Also filters out items without poster images.
  List<dynamic> _filterAndSortByDate(
    List<dynamic> items,
    String? Function(dynamic) getDateString,
  ) {
    final now = DateTime.now();

    final filtered = items.where((item) {
      // Filter out items without poster images
      final hasPoster =
          (item.posterPath != null && item.posterPath!.isNotEmpty);
      if (!hasPoster) return false;

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
