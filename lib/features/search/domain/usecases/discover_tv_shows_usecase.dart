import '../repositories/search_repository.dart';

class DiscoverTvShowsUseCase {
  final SearchRepository repository;

  DiscoverTvShowsUseCase(this.repository);

  Future<List<dynamic>> execute({
    int page = 1,
    int? genreId,
    String? language,
    int? year,
    String sortBy = 'popularity.desc',
    int? networkId,
    int? companyId,
  }) async {
    return await repository.discoverTvShows(
      page: page,
      genreId: genreId,
      language: language,
      year: year,
      sortBy: sortBy,
      networkId: networkId,
      companyId: companyId,
    );
  }
}
