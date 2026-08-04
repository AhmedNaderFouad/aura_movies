class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_path': profilePath,
      'order': order,
    };
  }
}

class CrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'job': job,
      'department': department,
      'profile_path': profilePath,
    };
  }
}

class MovieCredits {
  final List<CastMember> cast;
  final List<CrewMember> crew;

  MovieCredits({required this.cast, required this.crew});

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    return MovieCredits(
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((c) => CastMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      crew:
          (json['crew'] as List<dynamic>?)
              ?.map((c) => CrewMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cast': cast.map((c) => c.toJson()).toList(),
      'crew': crew.map((c) => c.toJson()).toList(),
    };
  }
}
