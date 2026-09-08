import '../../../../core/models/media.dart';

class TVShow implements Media {
  @override
  final int id;
  final String name;
  @override
  final String? backdropPath;
  @override
  final String? posterPath;
  @override
  final String overview;
  @override
  final double? voteAverage;
  final String? firstAirDate;
  @override
  final List<int> genreIds;

  @override
  String get title => name;

  @override
  String? get releaseDate => firstAirDate;

  @override
  bool get isTvShow => true;

  @override
  int? get voteCount => null;

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
