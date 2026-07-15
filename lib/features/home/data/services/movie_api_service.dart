import 'package:dio/dio.dart';

class MovieDioConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMTk0ZGQzZGI3YjJmYmRjODdjZmMyMGNiZGEzYjBkMiIsIm5iZiI6MTc3Nzk5Mjg1NC42Niwic3ViIjoiNjlmYTA0OTYwM2MyZTMwNjA1ZGFhZGQ0Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.96PELO8smmCnMik2dZjn2DRaM2Z6Edw4LkcO9Ut4soM';
}

class MovieApiService {
  late final Dio _dio;

  MovieApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: MovieDioConstants.baseUrl,
        headers: {
          'Authorization': 'Bearer ${MovieDioConstants.bearerToken}',
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<dynamic> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

   Future<dynamic> getNowPlayingMovies({int page = 1}) async {
     try {
       final response = await _dio.get(
         '/movie/now_playing',
         queryParameters: {'page': page},
       );
       return response.data;
     } catch (e) {
       rethrow;
     }
   }

   Future<dynamic> getPopularTvShows({int page = 1}) async {
     try {
       final response = await _dio.get(
         '/tv/popular',
         queryParameters: {'page': page},
       );
       return response.data;
     } catch (e) {
       rethrow;
     }
   }

   Future<dynamic> getUpcomingTvShows({int page = 1}) async {
     try {
       final response = await _dio.get(
         '/tv/on_the_air',
         queryParameters: {'page': page},
       );
       return response.data;
     } catch (e) {
       rethrow;
     }
   }

   Future<dynamic> getTvShowDetails(int tvShowId) async {
     try {
       final response = await _dio.get('/tv/$tvShowId');
       return response.data;
     } catch (e) {
       rethrow;
     }
   }

   Future<dynamic> getTvShowSeasonDetails(int tvShowId, int seasonNumber) async {
     try {
       final response = await _dio.get('/tv/$tvShowId/season/$seasonNumber');
       return response.data;
     } catch (e) {
       rethrow;
     }
   }

   Future<dynamic> getMovieDetails(int movieId) async {
     try {
       final response = await _dio.get('/movie/$movieId');
       return response.data;
     } catch (e) {
       rethrow;
     }
   }
}

