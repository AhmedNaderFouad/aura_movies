import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../domain/usecases/discover_movies_usecase.dart';
import '../../domain/usecases/discover_tv_shows_usecase.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase _searchMoviesUseCase;
  final DiscoverMoviesUseCase _discoverMoviesUseCase;
  final DiscoverTvShowsUseCase _discoverTvShowsUseCase;
  Timer? _debounce;

  SearchCubit({
    required SearchMoviesUseCase searchMoviesUseCase,
    required DiscoverMoviesUseCase discoverMoviesUseCase,
    required DiscoverTvShowsUseCase discoverTvShowsUseCase,
  }) : _searchMoviesUseCase = searchMoviesUseCase,
       _discoverMoviesUseCase = discoverMoviesUseCase,
       _discoverTvShowsUseCase = discoverTvShowsUseCase,
       super(SearchInitial());

  // Discovery Filters
  String selectedMediaType = 'all';
  int? selectedGenreId;
  String? selectedLanguage;
  int? selectedYear;
  int? selectedCompanyId;

  void setMediaType(String type) {
    if (selectedMediaType == type) return;
    selectedMediaType = type;
    selectedGenreId = null;
    performDiscover();
  }

  void setGenre(int? id) {
    if (selectedGenreId == id) return;
    selectedGenreId = id;
    performDiscover();
  }

  void setLanguage(String? lang) {
    if (selectedLanguage == lang) return;
    selectedLanguage = lang;
    performDiscover();
  }

  void setYear(int? year) {
    if (selectedYear == year) return;
    selectedYear = year;
    performDiscover();
  }

  void setCompany(int? id) {
    if (selectedCompanyId == id) return;
    selectedCompanyId = id;
    performDiscover();
  }

  Future<void> performDiscover() async {
    await discover(
      type: selectedMediaType,
      genreId: selectedGenreId,
      language: selectedLanguage,
      year: selectedYear,
      companyId: selectedCompanyId,
    );
  }

  Future<void> searchMovies(String query) async {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    emit(SearchLoading());
    try {
      final results = await _searchMoviesUseCase(query: query, page: 1);
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

  Future<void> discover({
    required String type,
    int? genreId,
    String? language,
    int? year,
    int? companyId,
  }) async {
    emit(SearchLoading());
    try {
      List<dynamic> results = [];
      if (type == 'all') {
        final responses = await Future.wait([
          _discoverMoviesUseCase.execute(
            genreId: genreId,
            language: language,
            year: year,
            companyId: companyId,
          ),
          _discoverTvShowsUseCase.execute(
            genreId: genreId,
            language: language,
            year: year,
            networkId: companyId,
          ),
        ]);
        results = [...responses[0], ...responses[1]];
        results.sort(
          (a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0),
        );
      } else if (type == 'movie') {
        results = await _discoverMoviesUseCase.execute(
          genreId: genreId,
          language: language,
          year: year,
          companyId: companyId,
        );
      } else {
        results = await _discoverTvShowsUseCase.execute(
          genreId: genreId,
          language: language,
          year: year,
          networkId: companyId,
        );
      }

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(results, isDiscover: true));
      }
    } catch (e) {
      emit(SearchError('Failed to discover: ${e.toString()}'));
    }
  }

  void resetFilters() {
    selectedMediaType = 'all';
    selectedGenreId = null;
    selectedLanguage = null;
    selectedYear = null;
    selectedCompanyId = null;
    _debounce?.cancel();
    emit(SearchInitial());
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
