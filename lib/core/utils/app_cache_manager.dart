import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  static const String key = 'auraMoviesCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Helper to clear all cached images
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
}
