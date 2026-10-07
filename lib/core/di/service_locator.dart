import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura_movies/core/network/dio_factory.dart';
import '../../../features/home/data/services/movie_api_service.dart';
import '../../../features/home/data/repositories/movie_repository_impl.dart';
import '../../../features/home/domain/repositories/movie_repository.dart';
import '../../../features/home/domain/usecases/get_popular_movies_usecase.dart';
import '../../../features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import '../../../features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import '../../../features/home/domain/usecases/get_upcoming_tv_shows_usecase.dart';
import '../../../features/home/domain/usecases/get_popular_tv_shows_usecase.dart';
import '../../../features/streaming/data/repositories/streaming_repository_impl.dart';
import '../../../features/streaming/domain/repositories/streaming_repository.dart';
import '../../../features/streaming/domain/usecases/get_streaming_sources_usecase.dart';
import '../../../features/streaming/presentation/cubit/server_selection_cubit.dart';
import '../../../features/home/presentation/cubit/home_cubit.dart';
import '../../../features/home/presentation/cubit/discover_media_cubit.dart';
import '../../../features/search/data/services/search_api_service.dart';
import '../../../features/search/data/repositories/search_repository_impl.dart';
import '../../../features/search/domain/repositories/search_repository.dart';
import '../../../features/search/domain/usecases/search_movies_usecase.dart';
import '../../../features/search/domain/usecases/discover_movies_usecase.dart';
import '../../../features/search/domain/usecases/discover_tv_shows_usecase.dart';
import '../../../features/search/presentation/cubit/search_cubit.dart';
import '../../../features/media_details/data/services/media_details_api_service.dart';
import '../../../features/media_details/data/repositories/media_details_repository_impl.dart';
import '../../../features/media_details/domain/repositories/media_details_repository.dart';
import '../../../features/media_details/domain/usecases/get_media_details_usecase.dart';
import '../../../features/media_details/domain/usecases/get_media_credits_usecase.dart';
import '../../../features/media_details/domain/usecases/get_media_recommendations_usecase.dart';
import '../../../features/media_details/presentation/cubit/media_details_cubit.dart';
import '../../../features/auth/data/datasources/remote_auth_datasource.dart';
import '../../../features/auth/data/datasources/local_auth_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/usecases/login_usecase.dart';
import '../../../features/auth/domain/usecases/signup_usecase.dart';
import '../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../../features/auth/domain/usecases/google_signin_usecase.dart';
import '../../../features/auth/domain/usecases/apple_signin_usecase.dart';
import '../../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../../features/auth/cubit/login_cubit.dart';
import '../../../features/auth/cubit/signup_cubit.dart';
import '../../../features/auth/cubit/forgot_password_cubit.dart';
import '../../../features/watchlist/data/datasources/watchlist_local_datasource.dart';
import '../../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../../features/watchlist/domain/repositories/watchlist_repository.dart';
import '../../../features/watchlist/domain/usecases/add_to_watchlist_usecase.dart';
import '../../../features/watchlist/domain/usecases/remove_from_watchlist_usecase.dart';
import '../../../features/watchlist/domain/usecases/get_watchlist_usecase.dart';
import '../../../features/watchlist/domain/usecases/is_in_watchlist_usecase.dart';
import '../../../features/watchlist/presentation/cubit/watchlist_cubit.dart';


final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Network (TMDB Dio)
  sl.registerLazySingleton<Dio>(() => DioFactory.createTmdbDio());

  // --- HOME FEATURE ---
  sl.registerLazySingleton<MovieApiService>(
    () => MovieApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<MovieRepositoryImpl>(
    () => MovieRepositoryImpl(apiService: sl<MovieApiService>()),
  );
  sl.registerLazySingleton<MovieRepository>(
    () => sl<MovieRepositoryImpl>(),
  );
  sl.registerLazySingleton<GetPopularMoviesUseCase>(
    () => GetPopularMoviesUseCase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetTopRatedMoviesUseCase>(
    () => GetTopRatedMoviesUseCase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetUpcomingMoviesUseCase>(
    () => GetUpcomingMoviesUseCase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetPopularTvShowsUseCase>(
    () => GetPopularTvShowsUseCase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetUpcomingTvShowsUseCase>(
    () => GetUpcomingTvShowsUseCase(sl<MovieRepository>()),
  );

  // --- SEARCH FEATURE ---
  sl.registerLazySingleton<SearchApiService>(
    () => SearchApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<SearchRepositoryImpl>(
    () => SearchRepositoryImpl(apiService: sl<SearchApiService>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => sl<SearchRepositoryImpl>(),
  );
  sl.registerLazySingleton<SearchMoviesUseCase>(
    () => SearchMoviesUseCase(sl<SearchRepository>()),
  );
  sl.registerLazySingleton<DiscoverMoviesUseCase>(
    () => DiscoverMoviesUseCase(sl<SearchRepository>()),
  );
  sl.registerLazySingleton<DiscoverTvShowsUseCase>(
    () => DiscoverTvShowsUseCase(sl<SearchRepository>()),
  );

  // --- MEDIA DETAILS FEATURE ---
  sl.registerLazySingleton<MediaDetailsApiService>(
    () => MediaDetailsApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<MediaDetailsRepositoryImpl>(
    () => MediaDetailsRepositoryImpl(apiService: sl<MediaDetailsApiService>()),
  );
  sl.registerLazySingleton<MediaDetailsRepository>(
    () => sl<MediaDetailsRepositoryImpl>(),
  );
  sl.registerLazySingleton<GetMediaDetailsUseCase>(
    () => GetMediaDetailsUseCase(sl<MediaDetailsRepository>()),
  );
  sl.registerLazySingleton<GetMediaCreditsUseCase>(
    () => GetMediaCreditsUseCase(sl<MediaDetailsRepository>()),
  );
  sl.registerLazySingleton<GetMediaRecommendationsUseCase>(
    () => GetMediaRecommendationsUseCase(sl<MediaDetailsRepository>()),
  );

  // --- AUTH FEATURE ---
  sl.registerLazySingleton<RemoteAuthDataSource>(
    () => RemoteAuthDataSourceImpl(),
  );
  sl.registerLazySingleton<LocalAuthDataSource>(
    () => LocalAuthDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<RemoteAuthDataSource>(),
      localDataSource: sl<LocalAuthDataSource>(),
    ),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignupUseCase>(
    () => SignupUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GoogleSignInUseCase>(
    () => GoogleSignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AppleSignInUseCase>(
    () => AppleSignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  // Check remember me on auth startup
  if (!(await sl<LocalAuthDataSource>().shouldRemember())) {
    await sl<AuthRepository>().signOut();
  }

  // --- WATCHLIST FEATURE ---
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(localDataSource: sl<WatchlistLocalDataSource>()),
  );
  sl.registerLazySingleton<AddToWatchlistUseCase>(
    () => AddToWatchlistUseCase(sl<WatchlistRepository>()),
  );
  sl.registerLazySingleton<RemoveFromWatchlistUseCase>(
    () => RemoveFromWatchlistUseCase(sl<WatchlistRepository>()),
  );
  sl.registerLazySingleton<GetWatchlistUseCase>(
    () => GetWatchlistUseCase(sl<WatchlistRepository>()),
  );
  sl.registerLazySingleton<IsInWatchlistUseCase>(
    () => IsInWatchlistUseCase(sl<WatchlistRepository>()),
  );

  // --- STREAMING FEATURE ---
  sl.registerLazySingleton<StreamingRepository>(
    () => StreamingRepositoryImpl(),
  );
  sl.registerLazySingleton<GetStreamingSourcesUseCase>(
    () => GetStreamingSourcesUseCase(sl<StreamingRepository>()),
  );

  // --- CUBITS ---
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      getPopularMoviesUseCase: sl<GetPopularMoviesUseCase>(),
      getTopRatedMoviesUseCase: sl<GetTopRatedMoviesUseCase>(),
      getUpcomingMoviesUseCase: sl<GetUpcomingMoviesUseCase>(),
      getPopularTvShowsUseCase: sl<GetPopularTvShowsUseCase>(),
      getUpcomingTvShowsUseCase: sl<GetUpcomingTvShowsUseCase>(),
    ),
  );
  sl.registerFactory<SearchCubit>(
    () => SearchCubit(
      searchMoviesUseCase: sl<SearchMoviesUseCase>(),
      discoverMoviesUseCase: sl<DiscoverMoviesUseCase>(),
      discoverTvShowsUseCase: sl<DiscoverTvShowsUseCase>(),
    ),
  );
  sl.registerFactory<DiscoverMediaCubit>(
    () => DiscoverMediaCubit(
      discoverMoviesUseCase: sl<DiscoverMoviesUseCase>(),
      discoverTvShowsUseCase: sl<DiscoverTvShowsUseCase>(),
    ),
  );
  sl.registerFactory<MediaDetailsCubit>(
    () => MediaDetailsCubit(
      getMediaDetailsUseCase: sl<GetMediaDetailsUseCase>(),
      getMediaCreditsUseCase: sl<GetMediaCreditsUseCase>(),
      getMediaRecommendationsUseCase: sl<GetMediaRecommendationsUseCase>(),
      repository: sl<MediaDetailsRepository>(),
    ),
  );
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      googleSignInUseCase: sl<GoogleSignInUseCase>(),
      appleSignInUseCase: sl<AppleSignInUseCase>(),
    ),
  );
  sl.registerFactory<SignupCubit>(
    () => SignupCubit(
      signupUseCase: sl<SignupUseCase>(),
      googleSignInUseCase: sl<GoogleSignInUseCase>(),
      appleSignInUseCase: sl<AppleSignInUseCase>(),
    ),
  );
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
    ),
  );
  sl.registerFactory<ServerSelectionCubit>(
    () => ServerSelectionCubit(sl<GetStreamingSourcesUseCase>()),
  );
  sl.registerLazySingleton<WatchlistCubit>(
    () => WatchlistCubit(
      addToWatchlistUseCase: sl<AddToWatchlistUseCase>(),
      removeFromWatchlistUseCase: sl<RemoveFromWatchlistUseCase>(),
      getWatchlistUseCase: sl<GetWatchlistUseCase>(),
      isInWatchlistUseCase: sl<IsInWatchlistUseCase>(),
    ),
  );
}
