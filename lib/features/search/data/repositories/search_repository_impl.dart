import '../../../home/data/models/movie_model.dart';
import '../../../home/data/models/tv_show_model.dart';
import '../../domain/repositories/search_repository.dart';
import '../services/search_api_service.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchApiService apiService;

  SearchRepositoryImpl({required this.apiService});

  @override
  Future<List<dynamic>> multiSearch({
    required String query,
    int page = 1,
  }) async {
    try {
      final data = await apiService.multiSearch(query: query, page: page);
      final results = data['results'] as List? ?? [];

      final List<dynamic> parsedResults = [];
      for (var item in results) {
        final mediaType = item['media_type'];
        if (mediaType == 'movie') {
          parsedResults.add(MovieModel.fromJson(item));
        } else if (mediaType == 'tv') {
          parsedResults.add(TVShowModel.fromJson(item));
        }
      }
      return parsedResults;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> discoverMovies({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'primary_release_date.desc',
    int? companyId,
    String? watchProviderIds,
    String? watchRegion = 'US',
    String? watchMonetizationType = 'flatrate',
  }) async {
    try {
      final data = await apiService.discoverMovies(
        page: page,
        genreId: genreId,
        language: language,
        year: year,
        sortBy: sortBy,
        companyId: companyId,
        watchProviderIds: watchProviderIds,
        watchRegion: watchRegion,
        watchMonetizationType: watchMonetizationType,
      );
      final results = data['results'] as List? ?? [];
      return results.map((item) => MovieModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> discoverTvShows({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'first_air_date.desc',
    int? networkId,
    int? companyId,
    String? watchProviderIds,
    String? watchRegion = 'US',
    String? watchMonetizationType = 'flatrate',
  }) async {
    try {
      final data = await apiService.discoverTvShows(
        page: page,
        genreId: genreId,
        language: language,
        year: year,
        sortBy: sortBy,
        networkId: networkId,
        companyId: companyId,
        watchProviderIds: watchProviderIds,
        watchRegion: watchRegion,
        watchMonetizationType: watchMonetizationType,
      );
      final results = data['results'] as List? ?? [];
      return results.map((item) => TVShowModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
