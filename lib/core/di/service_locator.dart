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
import '../../../features/movie_details/data/services/movie_details_api_service.dart';
import '../../../features/movie_details/data/repositories/movie_details_repository_impl.dart';
import '../../../features/movie_details/domain/usecases/get_movie_details_usecase.dart';
import '../../../features/movie_details/domain/usecases/get_movie_credits_usecase.dart';
import '../../../features/movie_details/domain/usecases/get_movie_recommendations_usecase.dart';
import '../../../features/tv_show_details/data/repositories/tv_show_details_repository_impl.dart';

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

  late final MovieDetailsApiService movieDetailsApiService;
  late final MovieDetailsRepositoryImpl movieDetailsRepository;
  late final GetMovieDetailsUseCase getMovieDetailsUseCase;
  late final GetMovieCreditsUseCase getMovieCreditsUseCase;
  late final GetMovieRecommendationsUseCase getMovieRecommendationsUseCase;

  late final TVShowDetailsRepositoryImpl tvShowDetailsRepository;

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

    final dioClient = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTk0ZGQzZGI3YjJmYmRjODdjZmMyMGNiZGEzYjBkMiIsIm5iZiI6MTc3Nzk5Mjg1NC42Niwic3ViIjoiNjlmYTA0OTYwM2MyZTMwNjA1ZGFhZGQ0Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.96PELO8smmCnMik2dZjn2DRaM2Z6Edw4LkcO9Ut4soM',
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    movieDetailsApiService = MovieDetailsApiService(dioClient);
    movieDetailsRepository = MovieDetailsRepositoryImpl(
      apiService: movieDetailsApiService,
    );
    getMovieDetailsUseCase = GetMovieDetailsUseCase(movieDetailsRepository);
    getMovieCreditsUseCase = GetMovieCreditsUseCase(movieDetailsRepository);
    getMovieRecommendationsUseCase = GetMovieRecommendationsUseCase(
      movieDetailsRepository,
    );

    tvShowDetailsRepository = TVShowDetailsRepositoryImpl(
      apiService: movieApiService,
    );
  }
}

final sl = ServiceLocator();
