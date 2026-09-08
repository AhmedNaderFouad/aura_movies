import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../domain/usecases/discover_movies_usecase.dart';
import '../../domain/usecases/discover_tv_shows_usecase.dart';
import '../utils/search_constants.dart';

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

  /// Determine if a studio/platform ID is a production company.
  bool _isProductionCompany(int id) {
    return SearchConstants.productionCompanies.containsKey(id);
  }

  /// Determine if a studio/platform ID is a streaming platform.
  bool _isStreamingPlatform(int id) {
    return SearchConstants.streamingPlatforms.containsKey(id);
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

      // Filter out items without poster images
      final filteredResults = results.where((item) {
        return item.posterPath != null && item.posterPath!.isNotEmpty;
      }).toList();

      if (filteredResults.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(filteredResults));
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

  /// Normalize and sort results by release date (newest first).
  /// Also filters out items without poster images.
  List<dynamic> _normalizeAndSort(List<dynamic> results) {
    // Filter out items without poster images
    results = results.where((item) {
      return item.posterPath != null && item.posterPath!.isNotEmpty;
    }).toList();

    // Sort by release date descending (newest first)
    results.sort((a, b) {
      DateTime? dateA = _parseReleaseDate(a.releaseDate);
      DateTime? dateB = _parseReleaseDate(b.releaseDate);

      // Handle null dates - put them at the end
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      // Sort descending (newest first)
      return dateB.compareTo(dateA);
    });

    return results;
  }

  /// Parse release date string to DateTime.
  DateTime? _parseReleaseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
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
        // Determine if companyId is a production company or streaming platform
        int? resolvedCompanyId;
        String? resolvedWatchProviderIds;

        if (companyId != null) {
          if (_isProductionCompany(companyId)) {
            resolvedCompanyId = companyId;
          } else if (_isStreamingPlatform(companyId)) {
            resolvedWatchProviderIds = companyId.toString();
          }
        }

        final responses = await Future.wait([
          _discoverMoviesUseCase.execute(
            genreId: genreId,
            language: language,
            year: year,
            companyId: resolvedCompanyId,
            watchProviderIds: resolvedWatchProviderIds,
            sortBy: 'primary_release_date.desc',
          ),
          _discoverTvShowsUseCase.execute(
            genreId: genreId,
            language: language,
            year: year,
            companyId: resolvedCompanyId,
            watchProviderIds: resolvedWatchProviderIds,
            sortBy: 'first_air_date.desc',
          ),
        ]);

        results = [...responses[0], ...responses[1]];
        // Normalize and sort by release date (newest first)
        results = _normalizeAndSort(results);
      } else if (type == 'movie') {
        // Determine if companyId is a production company or streaming platform
        int? resolvedCompanyId;
        String? resolvedWatchProviderIds;

        if (companyId != null) {
          if (_isProductionCompany(companyId)) {
            resolvedCompanyId = companyId;
          } else if (_isStreamingPlatform(companyId)) {
            resolvedWatchProviderIds = companyId.toString();
          }
        }

        results = await _discoverMoviesUseCase.execute(
          genreId: genreId,
          language: language,
          year: year,
          companyId: resolvedCompanyId,
          watchProviderIds: resolvedWatchProviderIds,
          sortBy: 'primary_release_date.desc',
        );
      } else if (type == 'tv') {
        // Determine if companyId is a production company or streaming platform
        int? resolvedCompanyId;
        String? resolvedWatchProviderIds;

        if (companyId != null) {
          if (_isProductionCompany(companyId)) {
            resolvedCompanyId = companyId;
          } else if (_isStreamingPlatform(companyId)) {
            resolvedWatchProviderIds = companyId.toString();
          }
        }

        results = await _discoverTvShowsUseCase.execute(
          genreId: genreId,
          language: language,
          year: year,
          companyId: resolvedCompanyId,
          watchProviderIds: resolvedWatchProviderIds,
          sortBy: 'first_air_date.desc',
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
