class CastMemberEntity {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  CastMemberEntity({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });
}

class CrewMemberEntity {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  CrewMemberEntity({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });
}

class MovieCreditsEntity {
  final List<CastMemberEntity> cast;
  final List<CrewMemberEntity> crew;

  MovieCreditsEntity({required this.cast, required this.crew});
}
