import '../../domain/entities/tv_show_details.dart';

class TVShowDetailsModel extends TVShowDetails {
  TVShowDetailsModel({
    required int id,
    required String name,
    required String overview,
    String? posterPath,
    String? backdropPath,
    required double voteAverage,
    String? firstAirDate,
    required List<SeasonModel> seasons,
  }) : super(
         id: id,
         name: name,
         overview: overview,
         posterPath: posterPath,
         backdropPath: backdropPath,
         voteAverage: voteAverage,
         firstAirDate: firstAirDate,
         seasons: seasons,
       );

  factory TVShowDetailsModel.fromJson(Map<String, dynamic> json) {
    return TVShowDetailsModel(
      id: json['id'],
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      firstAirDate: json['first_air_date'],
      seasons:
          (json['seasons'] as List?)
              ?.map((s) => SeasonModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class SeasonModel extends Season {
  SeasonModel({
    required int id,
    required String name,
    required int seasonNumber,
    required int episodeCount,
  }) : super(
         id: id,
         name: name,
         seasonNumber: seasonNumber,
         episodeCount: episodeCount,
       );

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'],
      name: json['name'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
    );
  }
}

class EpisodeModel extends Episode {
  EpisodeModel({
    required int id,
    required String name,
    required int episodeNumber,
    required String overview,
    String? stillPath,
  }) : super(
         id: id,
         name: name,
         episodeNumber: episodeNumber,
         overview: overview,
         stillPath: stillPath,
       );

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'],
      name: json['name'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      overview: json['overview'] ?? '',
      stillPath: json['still_path'],
    );
  }
}
