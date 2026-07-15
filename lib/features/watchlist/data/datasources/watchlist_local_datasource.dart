import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/data/models/movie_model.dart';

abstract class WatchlistLocalDataSource {
  Future<void> addToWatchlist(MovieModel movie);
  Future<void> removeFromWatchlist(int movieId);
  Future<List<MovieModel>> getWatchlist();
  Future<bool> isInWatchlist(int movieId);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _watchlistKey = 'CACHED_WATCHLIST';

  WatchlistLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> addToWatchlist(MovieModel movie) async {
    final watchlist = await getWatchlist();
    if (!watchlist.any((m) => m.id == movie.id)) {
      watchlist.add(movie);
      final jsonList = watchlist.map((m) => jsonEncode(m.toJson())).toList();
      await sharedPreferences.setStringList(_watchlistKey, jsonList);
    }
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    final watchlist = await getWatchlist();
    watchlist.removeWhere((m) => m.id == movieId);
    final jsonList = watchlist.map((m) => jsonEncode(m.toJson())).toList();
    await sharedPreferences.setStringList(_watchlistKey, jsonList);
  }

  @override
  Future<List<MovieModel>> getWatchlist() async {
    final jsonList = sharedPreferences.getStringList(_watchlistKey);
    if (jsonList != null) {
      return jsonList
          .map((jsonStr) => MovieModel.fromJson(jsonDecode(jsonStr)))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> isInWatchlist(int movieId) async {
    final watchlist = await getWatchlist();
    return watchlist.any((m) => m.id == movieId);
  }
}
