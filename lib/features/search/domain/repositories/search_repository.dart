abstract class SearchRepository {
  Future<List<dynamic>> multiSearch({required String query, int page = 1});

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
  });

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
  });
}
