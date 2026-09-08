class TmdbApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String bearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTk0ZGQzZGI3YjJmYmRjODdjZmMyMGNiZGEzYjBkMiIsIm5iZiI6MTc3Nzk5Mjg1NC42Niwic3ViIjoiNjlmYTA0OTYwM2MyZTMwNjA1ZGFhZGQ0Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.96PELO8smmCnMik2dZjn2DRaM2Z6Edw4LkcO9Ut4soM';
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
