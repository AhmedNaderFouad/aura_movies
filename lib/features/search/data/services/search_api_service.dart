import 'package:dio/dio.dart';

class SearchApiService {
  late final Dio _dio;

  SearchApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTk0ZGQzZGI3YjJmYmRjODdjZmMyMGNiZGEzYjBkMiIsIm5iZiI6MTc3Nzk5Mjg1NC42Niwic3ViIjoiNjlmYTA0OTYwM2MyZTMwNjA1ZGFhZGQ0Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.96PELO8smmCnMik2dZjn2DRaM2Z6Edw4LkcO9Ut4soM',
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<dynamic> multiSearch({required String query, int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {'query': query, 'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
