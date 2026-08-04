abstract class Media {
  int get id;
  String get title;
  String? get posterPath;
  String? get backdropPath;
  double? get voteAverage;
  int? get voteCount;
  String? get releaseDate;
  List<int> get genreIds;
  bool get isTvShow;
  String get overview;
}
