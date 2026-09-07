abstract class SearchRepository {
  Future<List<dynamic>> multiSearch({required String query, int page = 1});

  Future<List<dynamic>> discoverMovies({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'popularity.desc',
    int? companyId,
  });

  Future<List<dynamic>> discoverTvShows({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'popularity.desc',
    int? networkId,
    int? companyId,
  });
}
