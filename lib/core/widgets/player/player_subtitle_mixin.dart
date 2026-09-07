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
      if (subtitleTextNotifier.value.isNotEmpty)
        subtitleTextNotifier.value = '';
      return;
    }

    // Exact 150ms delay logic from your request
    final position =
        controller.value.position - const Duration(milliseconds: 150);

    int low = 0;
    int high = subtitleCues.length - 1;
    SubtitleCue? foundCue;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final cue = subtitleCues[mid];
      if (position >= cue.start && position <= cue.end) {
        foundCue = cue;
        break;
      } else if (position < cue.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    final newText = foundCue?.text ?? '';
    if (subtitleTextNotifier.value != newText)
      subtitleTextNotifier.value = newText;
  }

  void disposeSubtitleState() {
    subtitleTimer?.cancel();
    subtitleTextNotifier.dispose();
  }
}
