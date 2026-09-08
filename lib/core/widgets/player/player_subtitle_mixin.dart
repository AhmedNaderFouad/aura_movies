import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../features/subtitles/data/datasources/subtitle_parser.dart';
import '../../../features/subtitles/data/models/subtitle_model.dart';
import '../../../features/subtitles/domain/entities/subtitle_style_options.dart';
import '../../../features/subtitles/presentation/cubit/subtitle_cubit.dart';

mixin PlayerSubtitleMixin<T extends StatefulWidget> on State<T> {
  late SubtitleCubit subtitleCubit;
  final ValueNotifier<String> subtitleTextNotifier = ValueNotifier<String>('');

  SubtitleModel? currentSubtitle;
  List<SubtitleCue> subtitleCues = [];
  SubtitleStyleOptions subtitleStyle = const SubtitleStyleOptions();

  Timer? subtitleTimer;
  bool hasFetchedSubtitles = false;

  void initSubtitleState(SubtitleCubit cubit) {
    subtitleCubit = cubit;
    loadSubtitleSettings();
  }

  Future<void> loadSubtitleSettings() async {
    final savedOptions = await SubtitleStyleOptions.load();
    if (mounted) {
      setState(() => subtitleStyle = savedOptions);
    }
  }

  void fetchSubtitles({
    required int mediaId,
    required String mediaType,
    int? season,
    int? episode,
    String? imdbId,
  }) {
    if (hasFetchedSubtitles) return;
    hasFetchedSubtitles = true;

    subtitleCubit.fetchSubtitles(
      tmdbId: mediaId.toString(),
      imdbId: imdbId,
      isTv: mediaType == 'tv',
      season: season,
      episode: episode,
    );
  }

  Future<void> onSubtitleSelected(
    SubtitleModel? subtitle,
    VoidCallback onHideTimer,
  ) async {
    if (subtitle == null) {
      currentSubtitle = null;
      subtitleCues = [];
      subtitleTextNotifier.value = '';
      subtitleCubit.selectSubtitle(null);
      onHideTimer();
      return;
    }

    try {
      String? url = subtitle.url;
      if (subtitle.server == SubtitleServer.openSubtitles &&
          subtitle.fileId != null) {
        url = await subtitleCubit.getOpenSubtitlesUrl(subtitle.fileId!) ?? url;
      }
      if (url == null) return;

      final response = await Dio().get(
        url,
        options: Options(headers: {'User-Agent': 'AuraMovies v1.0.0'}),
      );
      if (response.statusCode == 200) {
        subtitleCues = SubtitleParser.parse(response.data.toString());
        currentSubtitle = subtitle;
        subtitleCubit.selectSubtitle(subtitle);
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('[PLAYBACK] Subtitle Load Error: $e');
    }
    onHideTimer();
  }

  void startSubtitleTimer(VideoPlayerController? controller) {
    if (subtitleTimer != null || !mounted) return;
    subtitleTimer = Timer.periodic(
      const Duration(milliseconds: 20),
      (_) => updateSubtitles(controller),
    );
  }

  void stopSubtitleTimer() {
    subtitleTimer?.cancel();
    subtitleTimer = null;
  }

  void updateSubtitles(VideoPlayerController? controller) {
    if (!mounted || controller == null || subtitleCues.isEmpty) {
      if (subtitleTextNotifier.value.isNotEmpty) {
        subtitleTextNotifier.value = '';
      }
      return;
    }

    // Use exact video position for perfect synchronization
    final position = controller.value.position;

    // Fast check: is the current position still within the last found cue?
    // This optimization helps during normal playback.
    // However, if we sought, we must do a full search.

    int low = 0;
    int high = subtitleCues.length - 1;
    List<String> foundTexts = [];

    // Binary search to find at least one matching cue
    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final cue = subtitleCues[mid];

      if (position >= cue.start && position <= cue.end) {
        // Found one match, now collect all overlapping matches
        List<int> indices = [mid];

        // Check backwards for overlaps
        int i = mid - 1;
        while (i >= 0 && subtitleCues[i].end >= position) {
          if (position >= subtitleCues[i].start) {
            indices.add(i);
          }
          i--;
        }

        // Check forwards for overlaps
        int j = mid + 1;
        while (j < subtitleCues.length && subtitleCues[j].start <= position) {
          if (position <= subtitleCues[j].end) {
            indices.add(j);
          }
          j++;
        }

        // Sort indices to maintain correct display order
        indices.sort();
        for (var index in indices) {
          foundTexts.add(subtitleCues[index].text);
        }
        break;
      } else if (position < cue.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    final newText = foundTexts.join('\n').trim();

    if (subtitleTextNotifier.value != newText) {
      subtitleTextNotifier.value = newText;
    }
  }

  void disposeSubtitleState() {
    subtitleTimer?.cancel();
    subtitleTextNotifier.dispose();
  }
}
