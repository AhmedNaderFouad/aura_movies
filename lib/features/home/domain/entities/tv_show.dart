class TVShow {
  final int id;
  final String name;
  final String? backdropPath;
  final String? posterPath;
  final String overview;
  final double? voteAverage;
  final String? firstAirDate;
  final List<int> genreIds;

  TVShow({
    required this.id,
    required this.name,
    this.backdropPath,
    this.posterPath,
    required this.overview,
    this.voteAverage,
    this.firstAirDate,
    required this.genreIds,
  });
}
