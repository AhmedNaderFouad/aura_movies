import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  MovieModel({
    required int id,
    required String title,
    String? backdropPath,
    String? posterPath,
    required String overview,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    required List<int> genreIds,
    bool isTvShow = false,
  }) : super(
         id: id,
         title: title,
         backdropPath: backdropPath,
         posterPath: posterPath,
         overview: overview,
         voteAverage: voteAverage,
         voteCount: voteCount,
         releaseDate: releaseDate,
         genreIds: genreIds,
         isTvShow: isTvShow,
       );

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      backdropPath: json['backdrop_path'],
      posterPath: json['poster_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      isTvShow: json['is_tv_show'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'backdrop_path': backdropPath,
      'poster_path': posterPath,
      'overview': overview,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'is_tv_show': isTvShow,
    };
  }
}
