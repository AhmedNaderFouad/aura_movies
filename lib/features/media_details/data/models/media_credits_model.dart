import '../../domain/entities/media_credits.dart';

class MediaCreditsModel extends MediaCredits {
  MediaCreditsModel({required super.cast, required super.crew});

  factory MediaCreditsModel.fromJson(Map<String, dynamic> json) {
    return MediaCreditsModel(
      cast:
          (json['cast'] as List?)
              ?.map((e) => MediaCastMemberModel.fromJson(e))
              .toList() ??
          [],
      crew:
          (json['crew'] as List?)
              ?.map((e) => MediaCrewMemberModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MediaCastMemberModel extends MediaCastMember {
  MediaCastMemberModel({
    required super.id,
    required super.name,
    required super.character,
    super.profilePath,
    required super.order,
  });

  factory MediaCastMemberModel.fromJson(Map<String, dynamic> json) {
    return MediaCastMemberModel(
      id: json['id'],
      name: json['name'],
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
      order: json['order'] ?? 0,
    );
  }
}

class MediaCrewMemberModel extends MediaCrewMember {
  MediaCrewMemberModel({
    required super.id,
    required super.name,
    required super.job,
    required super.department,
    super.profilePath,
  });

  factory MediaCrewMemberModel.fromJson(Map<String, dynamic> json) {
    return MediaCrewMemberModel(
      id: json['id'],
      name: json['name'],
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}
