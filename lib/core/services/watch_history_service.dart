import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/watch_media_model.dart';

class WatchHistoryService {
  static final WatchHistoryService _instance = WatchHistoryService._internal();
  factory WatchHistoryService() => _instance;
  WatchHistoryService._internal();

  final _historyController =
      StreamController<List<WatchMediaModel>>.broadcast();
  Stream<List<WatchMediaModel>> get historyStream => _historyController.stream;

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'aura_watch_history.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE watch_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tmdb_id INTEGER NOT NULL,
            media_type TEXT NOT NULL,
            data TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> saveProgress(WatchMediaModel media) async {
    final db = await _database;

    // Remove existing entry for same tmdb id & media type
    await db.delete(
      'watch_history',
      where: 'tmdb_id = ? AND media_type = ?',
      whereArgs: [media.id, media.mediaType],
    );

    final now = DateTime.now().toIso8601String();
    final data = jsonEncode(media.toJson());

    await db.insert('watch_history', {
      'tmdb_id': media.id,
      'media_type': media.mediaType,
      'data': data,
      'updated_at': now,
    });

    final list = await getWatchHistory();
    _historyController.add(list);
  }

  Future<List<WatchMediaModel>> getWatchHistory({
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await _database;
    final rows = await db.query(
      'watch_history',
      orderBy: 'updated_at DESC',
      limit: limit,
      offset: offset,
    );

    final list = rows
        .map((r) {
          try {
            final Map<String, dynamic> json = jsonDecode(r['data'] as String);
            return WatchMediaModel.fromJson(json);
          } catch (e) {
            debugPrint('Failed parsing watch history row: $e');
            return null;
          }
        })
        .whereType<WatchMediaModel>()
        .toList();

    _historyController.add(list);
    return list;
  }

  Future<void> removeFromHistory(int id, String mediaType) async {
    final db = await _database;
    await db.delete(
      'watch_history',
      where: 'tmdb_id = ? AND media_type = ?',
      whereArgs: [id, mediaType],
    );
    final list = await getWatchHistory();
    _historyController.add(list);
  }

  Future<void> close() async {
    await _historyController.close();
    await _db?.close();
    _db = null;
  }
}
