import 'tv_show_model.dart';

class TVShowResponseModel {
  final int page;
  final List<TVShowModel> results;
  final int totalPages;
  final int totalResults;

  TVShowResponseModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TVShowResponseModel.fromJson(Map<String, dynamic> json) {
    var resultsJson = json['results'] as List? ?? [];
    var results = resultsJson
        .map((tvShow) => TVShowModel.fromJson(tvShow as Map<String, dynamic>))
        .toList();

    return TVShowResponseModel(
      page: json['page'] ?? 1,
      results: results,
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'results': results.map((tvShow) => tvShow.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}
