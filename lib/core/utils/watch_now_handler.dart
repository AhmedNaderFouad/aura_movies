import 'package:flutter/material.dart';
import '../models/video_source_model.dart';
import '../widgets/native_video_player.dart';
import '../widgets/server_selection_bottom_sheet.dart';

class WatchNowHandler {
  /// Orchestrates the transition from media selection to playback
  static Future<void> handleWatchNow({
    required BuildContext context,
    required String tmdbId,
    String? imdbId,
    required String title,
    String? posterPath,
    bool isTvShow = false,
    int? season,
    int? episode,
    String? originalLanguage,
    Duration? startPosition,
    String? initialSubtitle,
  }) async {
    // 1. Trigger the modern Floating Server Selection Dialog
    final VideoSource? source = await showDialog<VideoSource>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => ServerSelectionBottomSheet(
        tmdbId: tmdbId,
        type: isTvShow ? 'tv' : 'movie',
        season: season,
        episode: episode,
        originalLanguage: originalLanguage,
      ),
    );

    if (source == null) return; // Silent exit if user cancels

    if (!context.mounted) return;

    // 2. Perform smooth navigation to the Player Screen
    // Initialization and Error Handling are encapsulated within the Player for better UX
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NativeVideoPlayer(
          source: source,
          title: title,
          mediaId: int.tryParse(tmdbId) ?? 0,
          imdbId: imdbId,
          mediaType: isTvShow ? 'tv' : 'movie',
          posterPath: posterPath,
          seasonNumber: season,
          episodeNumber: episode,
          originalLanguage: originalLanguage,
          startPosition: startPosition,
          initialSubtitle: initialSubtitle,
        ),
      ),
    );
  }
}
