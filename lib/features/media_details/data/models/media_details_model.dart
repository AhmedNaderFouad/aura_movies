import 'package:aura_movies/core/constants/media_type.dart';
import '../../domain/entities/media_details.dart';

class MediaDetailsModel extends MediaDetails {
  MediaDetailsModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    super.releaseDate,
    required super.originalLanguage,
    required super.genres,
    required super.status,
    super.tagline,
    required super.mediaType,
    super.budget,
    super.revenue,
    super.runtime,
    super.imdbId,
    super.seasons,
  });

  factory MediaDetailsModel.fromJson(
    Map<String, dynamic> json,
    MediaType type,
  ) {
    return MediaDetailsModel(
      id: json['id'],
      title: type == MediaType.movie ? json['title'] : json['name'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: type == MediaType.movie
          ? json['release_date']
          : json['first_air_date'],
      originalLanguage: json['original_language'] ?? '',
      genres:
          (json['genres'] as List?)
              ?.map((e) => MediaGenreModel.fromJson(e))
              .toList() ??
          [],
      status: json['status'] ?? '',
      tagline: json['tagline'],
      mediaType: type,
      budget: json['budget'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      imdbId: json['imdb_id'],
      seasons:
          (json['seasons'] as List?)
              ?.map((e) => MediaSeasonModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MediaGenreModel extends MediaGenre {
  MediaGenreModel({required super.id, required super.name});

  factory MediaGenreModel.fromJson(Map<String, dynamic> json) {
    return MediaGenreModel(id: json['id'], name: json['name']);
  }
}

class MediaSeasonModel extends MediaSeason {
  MediaSeasonModel({
    required super.id,
    required super.name,
    required super.seasonNumber,
    required super.episodeCount,
  });

  factory MediaSeasonModel.fromJson(Map<String, dynamic> json) {
    return MediaSeasonModel(
      id: json['id'],
      name: json['name'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
    );
  }
}

class MediaEpisodeModel extends MediaEpisode {
  MediaEpisodeModel({
    required super.id,
    required super.name,
    required super.episodeNumber,
    required super.overview,
    super.stillPath,
  });

  factory MediaEpisodeModel.fromJson(Map<String, dynamic> json) {
    return MediaEpisodeModel(
      id: json['id'],
      name: json['name'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      overview: json['overview'] ?? '',
      stillPath: json['still_path'],
    );
  }
}
