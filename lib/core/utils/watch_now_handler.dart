import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../features/subtitles/data/datasources/wyzie_subtitle_service.dart';
import '../../features/subtitles/data/datasources/open_subtitles_service.dart';
import '../../features/subtitles/data/repositories/subtitle_repository_impl.dart';
import '../../features/subtitles/presentation/cubit/subtitle_cubit.dart';
import '../models/video_source_model.dart';
import '../widgets/native_video_player.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/server_selection_bottom_sheet.dart';
import '../theme/app_colors.dart';
import '../services/media_playback_service.dart';

class WatchNowHandler {
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
    // 1. Show Server Selection Bottom Sheet
    final VideoSource? source = await showModalBottomSheet<VideoSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServerSelectionBottomSheet(
        tmdbId: tmdbId,
        type: isTvShow ? 'tv' : 'movie',
        season: season,
        episode: episode,
        originalLanguage: originalLanguage,
      ),
    );

    if (source == null) return; // User cancelled

    if (!context.mounted) return;

    // 2. Show loading dialog ("Preparing stream...")
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
              "Preparing stream...",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );

    VideoPlayerController? controller;
    final subtitleCubit = SubtitleCubit(
      SubtitleRepositoryImpl(
        wyzieService: SubtitleService(),
        openSubtitlesService: OpenSubtitlesService(),
      ),
    );

    try {
      // 3. Trigger CONCURRENT INITIALIZATION

      // A. Start Subtitle Fetching (Non-blocking)
      subtitleCubit.fetchSubtitles(
        tmdbId: tmdbId,
        imdbId: imdbId,
        isTv: isTvShow,
        season: season,
        episode: episode,
      );

      // B. Start Media Playback Initialization (The only blocking operation)
      debugPrint('[PLAYBACK] User requested playback for: $title');
      debugPrint('[PLAYBACK] Media initialization started');

      controller = await MediaPlaybackService.initializeController(
        source: source,
      ).timeout(const Duration(seconds: 30));

      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.pop(context);

        debugPrint('[PLAYBACK] Navigation started to Playback Screen');
        // 4. Navigate directly to Native Video Player
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NativeVideoPlayer(
              source: source,
              title: title,
              mediaId: int.tryParse(tmdbId) ?? 0,
              mediaType: isTvShow ? 'tv' : 'movie',
              posterPath: posterPath,
              seasonNumber: season,
              episodeNumber: episode,
              startPosition: startPosition,
              initialSubtitle: initialSubtitle,
              preInitializedController: controller,
              preInitializedSubtitleCubit: subtitleCubit,
            ),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Error in handleWatchNow: $e');
      debugPrint(stack.toString());

      controller?.dispose();
      subtitleCubit.close();

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
