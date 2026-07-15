abstract class SearchRepository {
  Future<List<dynamic>> multiSearch({
    required String query,
    int page = 1,
  });
}

