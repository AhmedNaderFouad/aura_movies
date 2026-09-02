class TVShowDetails {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? firstAirDate;
  final String originalLanguage;
  final List<Season> seasons;

  TVShowDetails({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.firstAirDate,
    required this.originalLanguage,
    required this.seasons,
  });
}

class Season {
  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;

  Season({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
  });
}

class Episode {
  final int id;
  final String name;
  final int episodeNumber;
  final String overview;
  final String? stillPath;

  Episode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.overview,
    this.stillPath,
  });
}
