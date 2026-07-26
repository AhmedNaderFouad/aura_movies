import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/video_extractor_service.dart';
import '../services/subtitle_service.dart';
import '../models/video_source_model.dart';
import '../widgets/native_video_player.dart';
import '../theme/app_colors.dart';

class WatchNowHandler {
  static final VideoScraperService _extractorService = VideoScraperService();
  static final SubtitleService _subtitleService = SubtitleService();

  static Future<void> handleWatchNow({
    required BuildContext context,
    required String tmdbId,
    String? imdbId,
    required String title,
    bool isTvShow = false,
    int? season,
    int? episode,
  }) async {
    // 1. Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20.h),
            Text(
              "Initializing player...",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );

    try {
      // 2. Call backend APIs in parallel
      final results = await Future.wait([
        _extractorService.extractSources(
          type: isTvShow ? 'tv' : 'movie',
          tmdbId: tmdbId,
          season: season,
          episode: episode,
        ),
        _subtitleService.fetchSubtitles(
          tmdbId: tmdbId,
          imdbId: imdbId,
          isTv: isTvShow,
          season: season,
          episode: episode,
        ),
      ]);

      final sources = results[0] as List<VideoSource>;
      final externalSubtitles = results[1] as List<SubtitleModel>;

      debugPrint('Extracted Sources: ${sources.length}');
      debugPrint('Fetched External Subtitles: ${externalSubtitles.length}');

      // Combine external subtitles with each VideoSource
      final List<VideoSource> combinedSources = sources.map((source) {
        final List<SubtitleModel> allSubtitles = [
          ...source.subtitles,
          ...externalSubtitles,
        ];
        
        // Remove duplicate subtitles by URL if any
        final uniqueSubtitles = <String, SubtitleModel>{};
        for (var sub in allSubtitles) {
          if (sub.url != null) {
            uniqueSubtitles[sub.url!] = sub;
          }
        }

        final combined = source.copyWith(subtitles: uniqueSubtitles.values.toList());
        debugPrint('Source ${source.name} now has ${combined.subtitles.length} subtitles');
        return combined;
      }).toList();

      // Dismiss loading dialog
      if (context.mounted) Navigator.pop(context);

      if (combinedSources.isEmpty) {
        _showError(context);
        return;
      }

      // 3. Selection Hierarchy & Sorting
      final List<VideoSource> sortedSources = List<VideoSource>.from(combinedSources);
      sortedSources.sort((a, b) {
        final aHasHls = a.hlsUrl != null && a.hlsUrl!.isNotEmpty;
        final bHasHls = b.hlsUrl != null && b.hlsUrl!.isNotEmpty;
        final aHasSubs = a.subtitles.isNotEmpty;
        final bHasSubs = b.subtitles.isNotEmpty;

        if (aHasHls && aHasSubs && !(bHasHls && bHasSubs)) return -1;
        if (!(aHasHls && aHasSubs) && bHasHls && bHasSubs) return 1;
        if (aHasHls && !bHasHls) return -1;
        if (!aHasHls && bHasHls) return 1;
        return 0;
      });

      // Check if we have at least one valid source
      if (sortedSources.isEmpty || 
          sortedSources.first.hlsUrl == null || 
          sortedSources.first.hlsUrl!.isEmpty) {
        _showError(context);
        return;
      }

      // 4. Navigate to Native Video Player with all sources for fallback
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NativeVideoPlayer(
              sources: sortedSources,
              title: title,
            ),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Error in handleWatchNow: $e');
      debugPrint(stack.toString());
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context);
      }
    }
  }

  static void _showError(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Film not available now"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
