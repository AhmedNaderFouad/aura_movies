import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../../domain/usecases/search_movies_usecase.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase searchMoviesUseCase;
  Timer? _debounce;

  SearchCubit({required this.searchMoviesUseCase}) : super(SearchInitial());

  Future<void> searchMovies(String query) async {
    // Cancel previous debounce timer
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Add debounce delay to prevent too many API calls
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    emit(SearchLoading());
    try {
      final results = await searchMoviesUseCase(query: query, page: 1);

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(results));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(SearchNoInternet());
      } else {
        emit(SearchError('Failed to search: ${e.toString()}'));
      }
    } catch (e) {
      emit(SearchError('Failed to search: ${e.toString()}'));
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
