import '../../domain/entities/movie_details.dart' as entities;

class GenreModel extends entities.Genre {
  GenreModel({
    required int id,
    required String name,
  }) : super(
    id: id,
    name: name,
  );

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ProductionCompanyModel extends entities.ProductionCompany {
  ProductionCompanyModel({
    required int id,
    String? logoPath,
    required String name,
    String? originCountry,
  }) : super(
    id: id,
    logoPath: logoPath,
    name: name,
    originCountry: originCountry,
  );

  factory ProductionCompanyModel.fromJson(Map<String, dynamic> json) {
    return ProductionCompanyModel(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logo_path': logoPath,
      'name': name,
      'origin_country': originCountry,
    };
  }
}

class ProductionCountryModel extends entities.ProductionCountry {
  ProductionCountryModel({
    required String iso31661,
    required String name,
  }) : super(
    iso31661: iso31661,
    name: name,
  );

  factory ProductionCountryModel.fromJson(Map<String, dynamic> json) {
    return ProductionCountryModel(
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iso_3166_1': iso31661,
      'name': name,
    };
  }
}

class SpokenLanguageModel extends entities.SpokenLanguage {
  SpokenLanguageModel({
    required String englishName,
    required String iso6391,
    required String name,
  }) : super(
    englishName: englishName,
    iso6391: iso6391,
    name: name,
  );

  factory SpokenLanguageModel.fromJson(Map<String, dynamic> json) {
    return SpokenLanguageModel(
      englishName: json['english_name'] ?? '',
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'english_name': englishName,
      'iso_639_1': iso6391,
      'name': name,
    };
  }
}

class MovieDetailsModel extends entities.MovieDetails {
  MovieDetailsModel({
    required bool adult,
    String? backdropPath,
    int? budget,
    required List<GenreModel> genres,
    String? homepage,
    required int id,
    String? imdbId,
    required List<String> originCountry,
    required String originalLanguage,
    required String originalTitle,
    required String overview,
    required double popularity,
    String? posterPath,
    required List<ProductionCompanyModel> productionCompanies,
    required List<ProductionCountryModel> productionCountries,
    String? releaseDate,
    int? revenue,
    int? runtime,
    required String status,
    String? tagline,
    required String title,
    required bool video,
    required double voteAverage,
    required int voteCount,
  }) : super(
    adult: adult,
    backdropPath: backdropPath,
    budget: budget,
    genres: genres,
    homepage: homepage,
    id: id,
    imdbId: imdbId,
    originCountry: originCountry,
    originalLanguage: originalLanguage,
    originalTitle: originalTitle,
    overview: overview,
    popularity: popularity,
    posterPath: posterPath,
    productionCompanies: productionCompanies,
    productionCountries: productionCountries,
    releaseDate: releaseDate,
    revenue: revenue,
    runtime: runtime,
    status: status,
    tagline: tagline,
    title: title,
    video: video,
    voteAverage: voteAverage,
    voteCount: voteCount,
  );

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      budget: json['budget'],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => GenreModel.fromJson(g as Map<String, dynamic>))
          .toList() ?? [],
      homepage: json['homepage'],
      id: json['id'] ?? 0,
      imdbId: json['imdb_id'],
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      posterPath: json['poster_path'],
      productionCompanies: (json['production_companies'] as List<dynamic>?)
          ?.map((c) => ProductionCompanyModel.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      productionCountries: (json['production_countries'] as List<dynamic>?)
          ?.map((c) => ProductionCountryModel.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      releaseDate: json['release_date'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      status: json['status'] ?? '',
      tagline: json['tagline'],
      title: json['title'] ?? '',
      video: json['video'] ?? false,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adult': adult,
      'backdrop_path': backdropPath,
      'budget': budget,
      'genres': genres.map((g) => (g as GenreModel).toJson()).toList(),
      'homepage': homepage,
      'id': id,
      'imdb_id': imdbId,
      'origin_country': originCountry,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'overview': overview,
      'popularity': popularity,
      'poster_path': posterPath,
      'production_companies': productionCompanies
          .map((c) => (c as ProductionCompanyModel).toJson())
          .toList(),
      'production_countries': productionCountries
          .map((c) => (c as ProductionCountryModel).toJson())
          .toList(),
      'release_date': releaseDate,
      'revenue': revenue,
      'runtime': runtime,
      'status': status,
      'tagline': tagline,
      'title': title,
      'video': video,
      'vote_average': voteAverage,
      'vote_count': voteCount,
    };
  }
}

