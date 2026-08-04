import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/video_extractor_service.dart';
import '../services/subtitle_service.dart';
import '../models/video_source_model.dart';
import '../widgets/native_video_player.dart';
import '../widgets/custom_snackbar.dart';
import '../theme/app_colors.dart';

class WatchNowHandler {
  static final VideoScraperService _extractorService = VideoScraperService();
  static final SubtitleService _subtitleService = SubtitleService();

  static Future<void> handleWatchNow({
    required BuildContext context,
    required String tmdbId,
    String? imdbId,
    required String title,
    String? posterPath,
    bool isTvShow = false,
    int? season,
    int? episode,
    Duration? startPosition,
    String? initialSubtitle,
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
        _extractorService.extractVidsrcSource(
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

      final VideoSource? source = results[0] as VideoSource?;
      final List<SubtitleModel> wyzieSubs = results[1] as List<SubtitleModel>;

      // Dismiss loading dialog
      if (context.mounted) Navigator.pop(context);

      if (source == null || source.hlsUrl == null || source.hlsUrl!.isEmpty) {
        if (context.mounted) _showError(context, isTvShow);
        return;
      }

      final finalSource = source.copyWith(subtitles: wyzieSubs);

      debugPrint(
        'Final Source ${finalSource.name} has ${finalSource.subtitles.length} external subtitles from Wyzie',
      );

      // 3. Navigate to Native Video Player
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NativeVideoPlayer(
              source: finalSource,
              title: title,
              mediaId: int.tryParse(tmdbId) ?? 0,
              mediaType: isTvShow ? 'tv' : 'movie',
              posterPath: posterPath,
              seasonNumber: season,
              episodeNumber: episode,
              startPosition: startPosition,
              initialSubtitle: initialSubtitle,
            ),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Error in handleWatchNow: $e');
      debugPrint(stack.toString());
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, isTvShow);
      }
    }
  }

  static void _showError(BuildContext context, bool isTvShow) {
    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: isTvShow
            ? 'TV Show not available now'
            : 'Film not available now',
        isError: true,
      );
    }
  }
}
