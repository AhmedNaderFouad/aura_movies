import 'package:aura_movies/core/constants/media_type.dart';

class MediaGenre {
  final int id;
  final String name;

  MediaGenre({required this.id, required this.name});
}

class MediaSeason {
  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;

  MediaSeason({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
  });
}

class MediaEpisode {
  final int id;
  final String name;
  final int episodeNumber;
  final String overview;
  final String? stillPath;

  MediaEpisode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.overview,
    this.stillPath,
  });
}

class MediaDetails {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final String originalLanguage;
  final List<MediaGenre> genres;
  final String status;
  final String? tagline;
  final MediaType mediaType;

  // Movie specific
  final int? budget;
  final int? revenue;
  final int? runtime;
  final String? imdbId;

  // TV specific
  final List<MediaSeason> seasons;

  MediaDetails({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    required this.originalLanguage,
    required this.genres,
    required this.status,
    this.tagline,
    required this.mediaType,
    this.budget,
    this.revenue,
    this.runtime,
    this.imdbId,
    this.seasons = const [],
  });

  bool get isTvShow => mediaType == MediaType.tv;
}
