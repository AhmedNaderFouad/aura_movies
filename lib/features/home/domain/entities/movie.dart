import '../../../../core/models/media.dart';

class Movie implements Media {
  @override
  final int id;
  @override
  final String title;
  @override
  final String? backdropPath;
  @override
  final String? posterPath;
  @override
  final String overview;
  @override
  final double? voteAverage;
  @override
  final int? voteCount;
  @override
  final String? releaseDate;
  @override
  final List<int> genreIds;
  @override
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
