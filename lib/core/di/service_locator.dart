import 'package:dio/dio.dart';
import '../../../features/home/data/services/movie_api_service.dart';
import '../../../features/home/data/repositories/movie_repository_impl.dart';
import '../../../features/home/domain/usecases/get_popular_movies_usecase.dart';
import '../../../features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import '../../../features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import '../../../features/home/domain/usecases/get_upcoming_tv_shows_usecase.dart';
import '../../../features/home/domain/usecases/get_popular_tv_shows_usecase.dart';
import '../../../features/search/data/services/search_api_service.dart';
import '../../../features/search/data/repositories/search_repository_impl.dart';
import '../../../features/search/domain/usecases/search_movies_usecase.dart';
import '../../../features/search/domain/usecases/discover_movies_usecase.dart';
import '../../../features/search/domain/usecases/discover_tv_shows_usecase.dart';
import '../../../features/media_details/data/services/media_details_api_service.dart';
import '../../../features/media_details/data/repositories/media_details_repository_impl.dart';
import '../../../features/media_details/domain/usecases/get_media_details_usecase.dart';
import '../../../features/media_details/domain/usecases/get_media_credits_usecase.dart';
import '../../../features/media_details/domain/usecases/get_media_recommendations_usecase.dart';
import '../constants/tmdb_api_constants.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final MovieApiService movieApiService;
  late final MovieRepositoryImpl movieRepository;
  late final GetPopularMoviesUseCase getPopularMoviesUseCase;
  late final GetTopRatedMoviesUseCase getTopRatedMoviesUseCase;
  late final GetUpcomingMoviesUseCase getUpcomingMoviesUseCase;
  late final GetPopularTvShowsUseCase getPopularTvShowsUseCase;
  late final GetUpcomingTvShowsUseCase getUpcomingTvShowsUseCase;

  late final SearchApiService searchApiService;
  late final SearchRepositoryImpl searchRepository;
  late final SearchMoviesUseCase searchMoviesUseCase;
  late final DiscoverMoviesUseCase discoverMoviesUseCase;
  late final DiscoverTvShowsUseCase discoverTvShowsUseCase;

  late final MediaDetailsApiService mediaDetailsApiService;
  late final MediaDetailsRepositoryImpl mediaDetailsRepository;
  late final GetMediaDetailsUseCase getMediaDetailsUseCase;
  late final GetMediaCreditsUseCase getMediaCreditsUseCase;
  late final GetMediaRecommendationsUseCase getMediaRecommendationsUseCase;

  void init() {
    movieApiService = MovieApiService();
    movieRepository = MovieRepositoryImpl(apiService: movieApiService);
    getPopularMoviesUseCase = GetPopularMoviesUseCase(movieRepository);
    getTopRatedMoviesUseCase = GetTopRatedMoviesUseCase(movieRepository);
    getUpcomingMoviesUseCase = GetUpcomingMoviesUseCase(movieRepository);
    getPopularTvShowsUseCase = GetPopularTvShowsUseCase(movieRepository);
    getUpcomingTvShowsUseCase = GetUpcomingTvShowsUseCase(movieRepository);

    searchApiService = SearchApiService();
    searchRepository = SearchRepositoryImpl(apiService: searchApiService);
    searchMoviesUseCase = SearchMoviesUseCase(searchRepository);

    // Initialize discovery use cases
    discoverMoviesUseCase = DiscoverMoviesUseCase(searchRepository);
    discoverTvShowsUseCase = DiscoverTvShowsUseCase(searchRepository);

    final dioClient = Dio(
      BaseOptions(
        baseUrl: TmdbApiConstants.baseUrl,
        headers: {
          'Authorization': 'Bearer ${TmdbApiConstants.bearerToken}',
          'Content-Type': 'application/json',
        },
        receiveTimeout: TmdbApiConstants.receiveTimeout,
        connectTimeout: TmdbApiConstants.connectTimeout,
        sendTimeout: TmdbApiConstants.sendTimeout,
      ),
    );
    mediaDetailsApiService = MediaDetailsApiService(dioClient);
    mediaDetailsRepository = MediaDetailsRepositoryImpl(
      apiService: mediaDetailsApiService,
    );
    getMediaDetailsUseCase = GetMediaDetailsUseCase(mediaDetailsRepository);
    getMediaCreditsUseCase = GetMediaCreditsUseCase(mediaDetailsRepository);
    getMediaRecommendationsUseCase = GetMediaRecommendationsUseCase(
      mediaDetailsRepository,
    );
  }
}

final sl = ServiceLocator();
