import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/video_source_model.dart';
import '../models/watch_media_model.dart';
import '../services/media_playback_service.dart';
import '../services/watch_history_service.dart';
import '../services/hls_quality_parser.dart';
import '../../features/subtitles/data/datasources/wyzie_subtitle_service.dart';
import '../../features/subtitles/data/datasources/open_subtitles_service.dart';
import '../../features/subtitles/presentation/cubit/subtitle_cubit.dart';
import '../../features/subtitles/data/repositories/subtitle_repository_impl.dart';
import './player/subtitle_overlay.dart';
import './player/player_subtitle_mixin.dart';
import './player/player_bottom_sheets_helper.dart';
import 'player_error_widget.dart';
import 'player_controls_overlay.dart';

class NativeVideoPlayer extends StatefulWidget {
  final VideoSource source;
  final String title;
  final int mediaId;
  final String? imdbId;
  final String mediaType;
  final String? posterPath;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? originalLanguage;
  final Duration? startPosition;
  final String? initialSubtitle;
  final VideoPlayerController? preInitializedController;
  final SubtitleCubit? preInitializedSubtitleCubit;

  const NativeVideoPlayer({
    super.key,
    required this.source,
    required this.title,
    required this.mediaId,
    this.imdbId,
    required this.mediaType,
    this.posterPath,
    this.seasonNumber,
    this.episodeNumber,
    this.originalLanguage,
    this.startPosition,
    this.initialSubtitle,
    this.preInitializedController,
    this.preInitializedSubtitleCubit,
  });

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer>
    with PlayerSubtitleMixin {
  // Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Services
  final WatchHistoryService _watchHistoryService = WatchHistoryService();
  final HlsQualityParser _qualityParser = HlsQualityParser();

  // State
  bool _hasError = false;
  bool _isInitializing = true;
  bool _showControls = false;
  bool _isBuffering = false;
  bool _playbackAuthorized = false;
  bool _routeTransitionComplete = false;

  Timer? _hideTimer;

  List<VideoQuality> _availableQualities = [];
  VideoQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();

    initSubtitleState(
      widget.preInitializedSubtitleCubit ??
          SubtitleCubit(
            SubtitleRepositoryImpl(
              wyzieService: SubtitleService(),
              openSubtitlesService: OpenSubtitlesService(),
            ),
          ),
    );

    WakelockPlus.enable();
    _setFullScreen();

    // 1. Start fetching subtitles immediately (Parallel with video init)
    _fetchSubtitles();

    if (widget.preInitializedController?.value.isInitialized ?? false) {
      _videoPlayerController = widget.preInitializedController;
      _videoPlayerController!.pause();

      if (widget.startPosition != null) {
        _videoPlayerController!.seekTo(widget.startPosition!);
      }

      _setupChewie();
      _videoPlayerController!.addListener(_onControllerUpdate);
      _isInitializing = false;
      _showControls = false;

      if (_availableQualities.isEmpty) {
        _loadQualities(widget.source.hlsUrl ?? '');
      }

      _startHideTimer();
    } else {
      _showControls = false;
      _initializePlayer(startAt: widget.startPosition);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routeTransitionComplete) {
      final route = ModalRoute.of(context);
      if (route?.animation?.isCompleted ?? true) {
        _routeTransitionComplete = true;
        _authorizePlayback();
      } else {
        route?.animation?.addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _routeTransitionComplete = true);
            _authorizePlayback();
          }
        });
      }
    }
  }

  void _authorizePlayback() {
    if (_playbackAuthorized || !_routeTransitionComplete) return;
    if (!mounted ||
        _videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }

    _playbackAuthorized = true;
    _videoPlayerController!.play();
    startSubtitleTimer(_videoPlayerController);
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
  }

  void _setupChewie() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
      showControls: false,
      showOptions: false,
      placeholder: const SizedBox.shrink(),
      errorBuilder: (context, errorMessage) => PlayerErrorWidget(
        onRetry: () => _initializePlayer(startAt: widget.startPosition),
      ),
    );
  }

  void _setFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initializePlayer({
    String? specificUrl,
    String? specificAudioUrl,
    Duration? startAt,
  }) async {
    String? url = specificUrl ?? widget.source.hlsUrl;
    if (url == null || url.isEmpty) {
      setState(() {
        _hasError = true;
        _isInitializing = false;
      });
      return;
    }

    if (_availableQualities.isEmpty && specificUrl == null) _loadQualities(url);

    try {
      if (specificUrl != null || _videoPlayerController != null) {
        _videoPlayerController?.removeListener(_onControllerUpdate);
        _videoPlayerController?.dispose();
        _chewieController?.dispose();
      }

      _videoPlayerController = await MediaPlaybackService.initializeController(
        source: widget.source,
        specificUrl: specificUrl,
        specificAudioUrl: specificAudioUrl,
      );

      await _videoPlayerController!.initialize();

      if (startAt != null) {
        await _videoPlayerController!.seekTo(startAt);
        // Ensure the player has time to buffer the frame at the new position
        await Future.delayed(const Duration(milliseconds: 300));
      }

      _setupChewie();
      _videoPlayerController!.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
          _playbackAuthorized = false;
        });

        _authorizePlayback();
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
    }
  }

  Future<void> _loadQualities(String masterUrl) async {
    final qualities = await _qualityParser.parseQualities(
      masterUrl,
      widget.source,
    );
    if (mounted) {
      setState(() {
        _availableQualities = qualities;
        _selectedQuality ??= qualities.first;
      });
    }
  }

  void _fetchSubtitles() {
    fetchSubtitles(
      mediaId: widget.mediaId,
      mediaType: widget.mediaType,
      season: widget.seasonNumber,
      episode: widget.episodeNumber,
      imdbId: widget.imdbId,
    );
  }

  void _onControllerUpdate() {
    if (!mounted || _videoPlayerController == null) return;

    if (_videoPlayerController!.value.hasError) {
      setState(() => _hasError = true);
      return;
    }

    final currentBuffering = _videoPlayerController!.value.isBuffering;
    if (currentBuffering != _isBuffering) {
      setState(() => _isBuffering = currentBuffering);
      if (currentBuffering)
        stopSubtitleTimer();
      else if (_videoPlayerController!.value.isPlaying)
        startSubtitleTimer(_videoPlayerController);
    }

    if (_videoPlayerController!.value.isPlaying)
      startSubtitleTimer(_videoPlayerController);
    else
      stopSubtitleTimer();

    if (_showControls && mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    if (_hasError) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _showQualitySelection() {
    PlayerBottomSheetsHelper.showQualitySelection(
      context: context,
      availableQualities: _availableQualities,
      selectedQuality: _selectedQuality,
      onQualitySelected: (quality) {
        if (_selectedQuality == quality) return;
        final currentPos =
            _videoPlayerController?.value.position ?? Duration.zero;
        setState(() {
          _selectedQuality = quality;
          _isInitializing = true;
        });
        _initializePlayer(
          specificUrl: quality.url,
          specificAudioUrl: quality.audioUrl,
          startAt: currentPos,
        );
      },
      onDismiss: _startHideTimer,
    );
  }

  void _showSubtitleSelection() {
    PlayerBottomSheetsHelper.showSubtitleSelection(
      context: context,
      subtitleCubit: subtitleCubit,
      sourceSubtitles: widget.source.subtitles,
      currentSubtitle: currentSubtitle,
      onSubtitleSelected: (subtitle) =>
          onSubtitleSelected(subtitle, _startHideTimer),
      onDismiss: _startHideTimer,
    );
  }

  void _showSubtitleSettings() {
    PlayerBottomSheetsHelper.showSubtitleSettings(
      context: context,
      initialOptions: subtitleStyle,
      onSettingsChanged: (newOptions) {
        setState(() => subtitleStyle = newOptions);
        newOptions.save();
      },
      onDismiss: _startHideTimer,
    );
  }

  Future<void> _saveProgress() async {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized)
      return;
    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;
    if (position.inSeconds < 10) return;

    await _watchHistoryService.saveProgress(
      WatchMediaModel(
        id: widget.mediaId,
        title: widget.title,
        posterPath: widget.posterPath,
        mediaType: widget.mediaType,
        lastPositionMs: position.inMilliseconds,
        totalDurationMs: duration.inMilliseconds,
        seasonNumber: widget.seasonNumber,
        episodeNumber: widget.episodeNumber,
        subtitleLanguageCode: currentSubtitle?.language,
        originalLanguage: widget.originalLanguage,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _saveProgress();
    _hideTimer?.cancel();
    disposeSubtitleState();
    _videoPlayerController?.removeListener(_onControllerUpdate);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    subtitleCubit.close();
    _resetOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveProgress();
          _resetOrientation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              if (_chewieController != null &&
                  (_videoPlayerController?.value.isInitialized ?? false) &&
                  !_isInitializing)
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  ),
                ),

              if (_isInitializing || _isBuffering)
                Container(
                  color: _isInitializing ? Colors.black : Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),

              ValueListenableBuilder<String>(
                valueListenable: subtitleTextNotifier,
                builder: (context, text, child) =>
                    SubtitleOverlay(subtitleText: text, style: subtitleStyle),
              ),

              BlocProvider.value(
                value: subtitleCubit,
                child: BlocListener<SubtitleCubit, SubtitleState>(
                  listener: (context, state) {
                    if (state.selectedSubtitle != null &&
                        currentSubtitle == null) {
                      onSubtitleSelected(
                        state.selectedSubtitle,
                        _startHideTimer,
                      );
                    }
                  },
                  child: PlayerControlsOverlay(
                    controller: _videoPlayerController,
                    title: widget.title,
                    isVisible: _showControls && !_hasError,
                    isInitializing: _isInitializing,
                    onBack: () => Navigator.pop(context),
                    onShowQuality: _showQualitySelection,
                    onShowSubtitleSettings: _showSubtitleSettings,
                    onShowSubtitles: _showSubtitleSelection,
                    onActionUserTap: _startHideTimer,
                  ),
                ),
              ),

              if (_hasError)
                PlayerErrorWidget(
                  onRetry: () {
                    setState(() {
                      _hasError = false;
                      _isInitializing = true;
                    });
                    _initializePlayer(startAt: widget.startPosition);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
