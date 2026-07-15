class Movie {
  final int id;
  final String title;
  final String? backdropPath;
  final String? posterPath;
  final String overview;
  final double? voteAverage;
  final int? voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final bool isTvShow;

  Movie({
    required this.id,
    required this.title,
    this.backdropPath,
    this.posterPath,
    required this.overview,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    required this.genreIds,
    this.isTvShow = false,
  });
}

