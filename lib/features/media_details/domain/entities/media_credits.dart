class MediaCastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  MediaCastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });
}

class MediaCrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  MediaCrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });
}

class MediaCredits {
  final List<MediaCastMember> cast;
  final List<MediaCrewMember> crew;

  MediaCredits({required this.cast, required this.crew});
}
