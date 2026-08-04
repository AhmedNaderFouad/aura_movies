import '../repositories/search_repository.dart';

class SearchMoviesUseCase {
  final SearchRepository repository;

  SearchMoviesUseCase(this.repository);

  Future<List<dynamic>> call({required String query, int page = 1}) async {
    return await repository.multiSearch(query: query, page: page);
  }
}
