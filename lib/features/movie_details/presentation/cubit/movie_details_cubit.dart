import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/entities/movie_credits.dart';
import '../../../home/domain/entities/movie.dart';
import '../../domain/usecases/get_movie_details_usecase.dart';
import '../../domain/usecases/get_movie_credits_usecase.dart';
import '../../domain/usecases/get_movie_recommendations_usecase.dart';

part 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final GetMovieDetailsUseCase getMovieDetailsUseCase;
  final GetMovieCreditsUseCase getMovieCreditsUseCase;
  final GetMovieRecommendationsUseCase getMovieRecommendationsUseCase;

  MovieDetailsCubit({
    required this.getMovieDetailsUseCase,
    required this.getMovieCreditsUseCase,
    required this.getMovieRecommendationsUseCase,
  }) : super(const MovieDetailsInitial());

  Future<void> loadMovieDetails(int movieId) async {
    try {
      emit(const MovieDetailsLoading());
      final movieDetails = await getMovieDetailsUseCase(movieId);
      final credits = await getMovieCreditsUseCase(movieId);
      final recommendations = await getMovieRecommendationsUseCase(movieId);
      emit(
        MovieDetailsLoaded(
          movieDetails,
          credits: credits,
          recommendations: recommendations,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(const MovieDetailsNoInternet());
      } else {
        emit(MovieDetailsError(e.toString()));
      }
    } catch (e) {
      emit(MovieDetailsError(e.toString()));
    }
  }
}
