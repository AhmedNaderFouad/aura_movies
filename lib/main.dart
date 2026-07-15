import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_theme.dart';
import 'package:aura_movies/core/routing/app_router.dart';
import 'package:aura_movies/core/routing/on_generate_route.dart';
import 'package:aura_movies/core/routing/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aura_movies/features/auth/data/services/auth_service.dart';
import 'package:aura_movies/features/watchlist/data/services/watchlist_service.dart';
import 'package:aura_movies/features/home/data/services/movie_api_service.dart';
import 'package:aura_movies/features/home/data/repositories/movie_repository_impl.dart';
import 'package:aura_movies/features/home/domain/usecases/get_popular_movies_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_upcoming_tv_shows_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_popular_tv_shows_usecase.dart';
import 'package:aura_movies/features/home/presentation/cubit/home_cubit.dart';
import 'package:aura_movies/features/browse/data/services/search_api_service.dart';
import 'package:aura_movies/features/browse/data/repositories/search_repository_impl.dart';
import 'package:aura_movies/features/browse/domain/usecases/search_movies_usecase.dart';
import 'package:aura_movies/features/browse/presentation/cubit/search_cubit.dart';
import 'package:aura_movies/features/movie_details/data/services/movie_details_api_service.dart';
import 'package:aura_movies/features/movie_details/data/repositories/movie_details_repository_impl.dart';
import 'package:aura_movies/features/movie_details/domain/usecases/get_movie_details_usecase.dart';
import 'package:aura_movies/features/movie_details/domain/usecases/get_movie_credits_usecase.dart';
import 'package:aura_movies/features/movie_details/presentation/cubit/movie_details_cubit.dart';
import 'package:aura_movies/features/tv_show_details/data/repositories/tv_show_details_repository_impl.dart';
import 'package:aura_movies/features/tv_show_details/presentation/cubit/tv_show_details_cubit.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:aura_movies/core/utils/app_cache_manager.dart';
import 'package:dio/dio.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Auth Service
  await AuthService.initialize();
  // Initialize Watchlist Service
  await WatchlistService.initialize();

  // Optional: Force clear cache on app restart if needed
  // await AppCacheManager.clearCache();

  runApp(const AuraMoviesApp());
}

class AuraMoviesApp extends StatelessWidget {
  const AuraMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Initialize repositories and use cases for home
        final movieApiService = MovieApiService();
        final movieRepository = MovieRepositoryImpl(apiService: movieApiService);
        final getPopularMoviesUseCase = GetPopularMoviesUseCase(movieRepository);
        final getTopRatedMoviesUseCase = GetTopRatedMoviesUseCase(movieRepository);
        final getUpcomingMoviesUseCase = GetUpcomingMoviesUseCase(movieRepository);
        final getPopularTvShowsUseCase = GetPopularTvShowsUseCase(movieRepository);
        final getUpcomingTvShowsUseCase = GetUpcomingTvShowsUseCase(movieRepository);

        // Initialize repositories and use cases for browse/search
        final searchApiService = SearchApiService();
        final searchRepository = SearchRepositoryImpl(apiService: searchApiService);
        final searchMoviesUseCase = SearchMoviesUseCase(searchRepository);

        // Initialize repositories and use cases for movie details
        final dioClient = Dio(
          BaseOptions(
            baseUrl: 'https://api.themoviedb.org/3',
            headers: {
              'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTk0ZGQzZGI3YjJmYmRjODdjZmMyMGNiZGEzYjBkMiIsIm5iZiI6MTc3Nzk5Mjg1NC42Niwic3ViIjoiNjlmYTA0OTYwM2MyZTMwNjA1ZGFhZGQ0Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.96PELO8smmCnMik2dZjn2DRaM2Z6Edw4LkcO9Ut4soM',
              'Content-Type': 'application/json',
            },
            receiveTimeout: const Duration(seconds: 30),
            connectTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          ),
        );
        final movieDetailsApiService = MovieDetailsApiService(dioClient);
        final movieDetailsRepository = MovieDetailsRepositoryImpl(apiService: movieDetailsApiService);
        final getMovieDetailsUseCase = GetMovieDetailsUseCase(movieDetailsRepository);
        final getMovieCreditsUseCase = GetMovieCreditsUseCase(movieDetailsRepository);

        // Initialize TV Show Details
        final tvShowDetailsRepository = TVShowDetailsRepositoryImpl(apiService: movieApiService);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AuraMovies',
          theme: AppTheme.darkTheme,
          navigatorKey: AppRouter.navigatorKey,
          onGenerateRoute: (settings) {
            // Provide HomeCubit when navigating to home screen
            if (settings.name == Routes.home) {
              return onGenerateRoute(settings);
            }
            return onGenerateRoute(settings);
          },
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => HomeCubit(
                    getPopularMoviesUseCase: getPopularMoviesUseCase,
                    getTopRatedMoviesUseCase: getTopRatedMoviesUseCase,
                    getUpcomingMoviesUseCase: getUpcomingMoviesUseCase,
                    getPopularTvShowsUseCase: getPopularTvShowsUseCase,
                    getUpcomingTvShowsUseCase: getUpcomingTvShowsUseCase,
                  ),
                ),
                BlocProvider(
                  create: (context) => SearchCubit(
                    searchMoviesUseCase: searchMoviesUseCase,
                  ),
                ),
                BlocProvider(
                  create: (context) => MovieDetailsCubit(
                    getMovieDetailsUseCase: getMovieDetailsUseCase,
                    getMovieCreditsUseCase: getMovieCreditsUseCase,
                  ),
                ),
                BlocProvider(
                  create: (context) => TVShowDetailsCubit(
                    repository: tvShowDetailsRepository,
                  ),
                ),
                BlocProvider(
                  create: (context) => WatchlistCubit(
                    addToWatchlistUseCase: WatchlistService.addToWatchlistUseCase,
                    removeFromWatchlistUseCase: WatchlistService.removeFromWatchlistUseCase,
                    getWatchlistUseCase: WatchlistService.getWatchlistUseCase,
                    isInWatchlistUseCase: WatchlistService.isInWatchlistUseCase,
                  ),
                ),
              ],
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: Routes.splash,
        );
      },
    );
  }
}
