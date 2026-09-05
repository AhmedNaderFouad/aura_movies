import 'media.dart';

class WatchMediaModel implements Media {
  @override
  final int id;
  @override
  final String title;
  @override
  final String? posterPath;

  final String mediaType; // 'movie' or 'tv'
  final int lastPositionMs;
  final int totalDurationMs;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? subtitleLanguageCode;
  final String? originalLanguage;
  final DateTime updatedAt;

  WatchMediaModel({
    required this.id,
    required this.title,
    this.posterPath,
    required this.mediaType,
    required this.lastPositionMs,
    required this.totalDurationMs,
    this.seasonNumber,
    this.episodeNumber,
    this.subtitleLanguageCode,
    this.originalLanguage,
    required this.updatedAt,
  });

  @override
  String? get backdropPath => null;
  @override
  double? get voteAverage => 0.0;
  @override
  int? get voteCount => 0;
  @override
  String? get releaseDate => null;
  @override
  List<int> get genreIds => [];
  @override
  bool get isTvShow => mediaType == 'tv';
  @override
  String get overview => '';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'posterPath': posterPath,
    'mediaType': mediaType,
    'lastPositionMs': lastPositionMs,
    'totalDurationMs': totalDurationMs,
    'seasonNumber': seasonNumber,
    'episodeNumber': episodeNumber,
    'subtitleLanguageCode': subtitleLanguageCode,
    'originalLanguage': originalLanguage,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WatchMediaModel.fromJson(Map<String, dynamic> json) =>
      WatchMediaModel(
        id: json['id'],
        title: json['title'],
        posterPath: json['posterPath'],
        mediaType: json['mediaType'],
        lastPositionMs: json['lastPositionMs'],
        totalDurationMs: json['totalDurationMs'],
        seasonNumber: json['seasonNumber'],
        episodeNumber: json['episodeNumber'],
        subtitleLanguageCode: json['subtitleLanguageCode'],
        originalLanguage: json['originalLanguage'],
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  double get progress =>
      totalDurationMs > 0 ? lastPositionMs / totalDurationMs : 0.0;
}
