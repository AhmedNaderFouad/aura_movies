import '../repositories/search_repository.dart';

class DiscoverMoviesUseCase {
  final SearchRepository repository;

  DiscoverMoviesUseCase(this.repository);

  Future<List<dynamic>> execute({
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
    return await repository.discoverMovies(
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
  }
}
