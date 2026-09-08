import '../repositories/search_repository.dart';

class DiscoverTvShowsUseCase {
  final SearchRepository repository;

  DiscoverTvShowsUseCase(this.repository);

  Future<List<dynamic>> execute({
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
    return await repository.discoverTvShows(
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
  }
}
