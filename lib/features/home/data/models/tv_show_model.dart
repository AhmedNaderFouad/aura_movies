import '../../domain/entities/tv_show.dart';

class TVShowModel extends TVShow {
  TVShowModel({
    required int id,
    required String name,
    String? backdropPath,
    String? posterPath,
    required String overview,
    double? voteAverage,
    String? firstAirDate,
    required List<int> genreIds,
  }) : super(
          id: id,
          name: name,
          backdropPath: backdropPath,
          posterPath: posterPath,
          overview: overview,
          voteAverage: voteAverage,
          firstAirDate: firstAirDate,
          genreIds: genreIds,
        );

  factory TVShowModel.fromJson(Map<String, dynamic> json) {
    return TVShowModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      backdropPath: json['backdrop_path'],
      posterPath: json['poster_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      firstAirDate: json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'backdrop_path': backdropPath,
      'poster_path': posterPath,
      'overview': overview,
      'vote_average': voteAverage,
      'first_air_date': firstAirDate,
      'genre_ids': genreIds,
    };
  }
}
