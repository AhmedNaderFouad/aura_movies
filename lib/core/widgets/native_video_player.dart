import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/video_source_model.dart';
import '../models/watch_media_model.dart';
import '../services/media_playback_service.dart';
import '../services/watch_history_service.dart';
import '../services/hls_quality_parser.dart';
import '../utils/video_header_utility.dart';
import '../../features/subtitles/domain/entities/subtitle_style_options.dart';
import '../../features/subtitles/data/datasources/wyzie_subtitle_service.dart';
import '../../features/subtitles/data/datasources/open_subtitles_service.dart';
import '../../features/subtitles/data/datasources/subtitle_parser.dart';
import '../../features/subtitles/data/models/subtitle_model.dart';
import '../../features/subtitles/presentation/cubit/subtitle_cubit.dart';
import '../../features/subtitles/data/repositories/subtitle_repository_impl.dart';
import '../../features/subtitles/presentation/widgets/subtitles_bottom_sheet.dart';
import '../../features/subtitles/presentation/widgets/subtitle_settings_bottom_sheet.dart';
import './player/subtitle_overlay.dart';
import 'custom_snackbar.dart';
import 'player_error_widget.dart';
import 'quality_selection_bottom_sheet.dart';
import 'player_controls_overlay.dart';

class NativeVideoPlayer extends StatefulWidget {
  final VideoSource source;
  final String title;
  final int mediaId;
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

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  // Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Services
  final WatchHistoryService _watchHistoryService = WatchHistoryService();
  final HlsQualityParser _qualityParser = HlsQualityParser();
  late SubtitleCubit _subtitleCubit;

  // State
  bool _hasError = false;
  bool _isInitializing = true;
  bool _showControls = false;
  bool _isBuffering = false;
  bool _hasFetchedSubtitles = false;
  bool _playbackAuthorized = false;
  bool _isTransitionListenerAttached = false;
  bool _routeTransitionStarted = false;
  bool _routeTransitionComplete = false;
  bool _hasLoggedFirstPlay = false;
  Timer? _hideTimer;
  Timer? _subtitleTimer;

  SubtitleModel? _currentSubtitle;
  List<SubtitleCue> _subtitleCues = [];
  String _currentSubtitleText = '';
  SubtitleStyleOptions _subtitleStyle = const SubtitleStyleOptions();

  List<VideoQuality> _availableQualities = [];
  VideoQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    debugPrint('[PLAYBACK] Playback screen mounted');
    _subtitleCubit =
        widget.preInitializedSubtitleCubit ??
        SubtitleCubit(
          SubtitleRepositoryImpl(
            wyzieService: SubtitleService(),
            openSubtitlesService: OpenSubtitlesService(),
          ),
        );

    WakelockPlus.enable();
    _setFullScreen();
    _loadSubtitleSettings();

    // Immediate Player Initialization
    if (widget.preInitializedController != null &&
        widget.preInitializedController!.value.isInitialized) {
      _videoPlayerController = widget.preInitializedController;
      debugPrint(
        '[PLAYBACK] Using pre-initialized controller. isPlaying: ${_videoPlayerController!.value.isPlaying}',
      );

      // Force PAUSED state until transition is done
      _videoPlayerController!.pause();
      debugPrint('[PLAYBACK] Force pause applied in initState');

      // Handle saved position for pre-initialized controller
      if (widget.startPosition != null) {
        _videoPlayerController!.seekTo(widget.startPosition!);
        debugPrint(
          '[PLAYBACK] Resume position applied: ${widget.startPosition}',
        );
      }

      _setupChewie();
      _videoPlayerController!.addListener(_onControllerUpdate);
      _isInitializing = false;

      // Still need to trigger qualities load if not present
      if (_availableQualities.isEmpty) {
        _loadQualities(widget.source.hlsUrl ?? '');
      }

      // Ensure subtitles are being fetched if not already started
      _fetchSubtitles();
    } else {
      _initializePlayer(startAt: widget.startPosition);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isTransitionListenerAttached) {
      _isTransitionListenerAttached = true;
      final route = ModalRoute.of(context);

      debugPrint('[PLAYBACK] Route animation listener attached');

      if (route != null && route.animation != null) {
        debugPrint(
          '[PLAYBACK] Initial route animation state: ${route.animation!.status}',
        );
        debugPrint(
          '[PLAYBACK] Initial route animation value: ${route.animation!.value}',
        );

        final animation = route.animation!;

        void listener(AnimationStatus status) {
          debugPrint('[PLAYBACK] Route animation status changed: $status');

          if (status == AnimationStatus.forward) {
            _routeTransitionStarted = true;
            debugPrint('[PLAYBACK] Real push transition started');
          }

          if (status == AnimationStatus.completed) {
            if (_routeTransitionStarted) {
              debugPrint('[PLAYBACK] Real route transition completed');
              _routeTransitionComplete = true;
              _authorizePlayback();
              animation.removeStatusListener(listener);
            } else {
              debugPrint(
                '[PLAYBACK] Ignoring initial completed status, waiting for forward',
              );
            }
          }
        }

        animation.addStatusListener(listener);

        debugPrint('[PLAYBACK] Waiting for real route transition to start');
      } else {
        debugPrint(
          '[PLAYBACK] No route animation found, authorizing immediately',
        );
        _routeTransitionComplete = true;
        _authorizePlayback();
      }
    }
  }

  void _authorizePlayback() {
    if (_playbackAuthorized) return;

    if (!_routeTransitionComplete) {
      debugPrint('[PLAYBACK] Authorization deferred: transition not complete');
      return;
    }

    if (!mounted ||
        _videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      debugPrint('[PLAYBACK] Authorization deferred: controller not ready');
      return;
    }

    debugPrint('[PLAYBACK] Playback authorized');
    _playbackAuthorized = true;
    _videoPlayerController!.play();
    _startSubtitleTimer();
    debugPrint('[PLAYBACK] play() called');
  }

  void _setupChewie() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false, // Strictly controlled by authorization logic
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
      showControls: false,
      showOptions: false,
      placeholder: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorBuilder: (context, errorMessage) => PlayerErrorWidget(
        onRetry: () => _initializePlayer(startAt: widget.startPosition),
      ),
    );
  }

  // --- Initialization & Lifecycle ---

  void _setFullScreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _loadSubtitleSettings() async {
    final savedOptions = await SubtitleStyleOptions.load();
    if (mounted) {
      setState(() => _subtitleStyle = savedOptions);
    }
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

    // Load qualities if not already loaded
    if (_availableQualities.isEmpty && specificUrl == null) {
      _loadQualities(url);
    }

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

      if (startAt != null) {
        await _videoPlayerController!.seekTo(startAt);
      }

      _setupChewie();

      _videoPlayerController!.addListener(_onControllerUpdate);

      // Ensure subtitles are fetched
      _fetchSubtitles();

      if (mounted) {
        setState(() => _isInitializing = false);

        // Since we are likely already on screen (quality change or fallback),
        // we can authorize immediately.
        _authorizePlayback();
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
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

  // --- Subtitles ---

  void _fetchSubtitles() {
    if (_hasFetchedSubtitles) return;
    _hasFetchedSubtitles = true;

    _subtitleCubit.fetchSubtitles(
      tmdbId: widget.mediaId.toString(),
      isTv: widget.mediaType == 'tv',
      season: widget.seasonNumber,
      episode: widget.episodeNumber,
    );
  }

  Future<void> _onSubtitleSelected(SubtitleModel? subtitle) async {
    if (subtitle == null) {
      setState(() {
        _currentSubtitle = null;
        _subtitleCues = [];
        _currentSubtitleText = '';
      });
      _subtitleCubit.selectSubtitle(null);
      _startHideTimer();
      return;
    }

    try {
      String? url = subtitle.url;
      if (subtitle.server == SubtitleServer.openSubtitles &&
          subtitle.fileId != null) {
        url = await _subtitleCubit.getOpenSubtitlesUrl(subtitle.fileId!) ?? url;
      }

      if (url == null) return;

      final response = await Dio().get(
        url,
        options: Options(headers: {'User-Agent': 'AuraMovies v1.0.0'}),
      );
      if (response.statusCode == 200) {
        final cues = SubtitleParser.parse(response.data.toString());
        setState(() {
          _currentSubtitle = subtitle;
          _subtitleCues = cues;
        });
        _subtitleCubit.selectSubtitle(subtitle);
      }
    } catch (e) {
      debugPrint('Error loading subtitle: $e');
    }
    _startHideTimer();
  }

  // --- UI Logic & Interactions ---

  void _onControllerUpdate() {
    if (!mounted || _videoPlayerController == null) return;

    if (_videoPlayerController!.value.hasError) {
      setState(() => _hasError = true);
      return;
    }

    final currentBuffering = _videoPlayerController!.value.isBuffering;
    if (currentBuffering != _isBuffering) {
      setState(() => _isBuffering = currentBuffering);
      if (currentBuffering) {
        _stopSubtitleTimer();
      } else if (_videoPlayerController!.value.isPlaying) {
        _startSubtitleTimer();
      }
    }

    if (_videoPlayerController!.value.isPlaying) {
      _startSubtitleTimer();
    } else {
      _stopSubtitleTimer();
    }

    if (_videoPlayerController!.value.isPlaying && !_hasLoggedFirstPlay) {
      _hasLoggedFirstPlay = true;
      debugPrint(
        '[PLAYBACK] First playing state detected at: ${_videoPlayerController!.value.position}',
      );
    }

    if (_showControls) {
      setState(() {});
    }
  }

  void _startSubtitleTimer() {
    if (_subtitleTimer != null || !mounted) return;
    _subtitleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateSubtitles();
    });
  }

  void _stopSubtitleTimer() {
    _subtitleTimer?.cancel();
    _subtitleTimer = null;
  }

  void _updateSubtitles() {
    if (!mounted || _videoPlayerController == null || _subtitleCues.isEmpty) {
      return;
    }

    final rawPosition = _videoPlayerController!.value.position;
    final offsetMs = (_subtitleStyle.syncOffset * 1000).toInt();
    final position = rawPosition + Duration(milliseconds: offsetMs);

    final currentCue = _subtitleCues.lastWhere(
      (cue) => position >= cue.start && position <= cue.end,
      orElse: () =>
          SubtitleCue(start: Duration.zero, end: Duration.zero, text: ''),
    );

    if (_currentSubtitleText != currentCue.text) {
      setState(() => _currentSubtitleText = currentCue.text);
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _showQualitySelection() {
    if (_availableQualities.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'No other qualities available',
        isError: false,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QualitySelectionBottomSheet(
        availableQualities: _availableQualities,
        currentQuality: _selectedQuality,
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
      ),
    ).then((_) => _startHideTimer());
  }

  void _showSubtitleSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: _subtitleCubit,
        child: BlocBuilder<SubtitleCubit, SubtitleState>(
          builder: (context, state) {
            return SubtitlesBottomSheet(
              wyzieSubtitles: [
                ...widget.source.subtitles,
                ...state.wyzieSubtitles,
              ],
              openSubtitles: state.openSubtitles,
              currentSubtitle: _currentSubtitle,
              onSubtitleSelected: _onSubtitleSelected,
              isLoading: state.isLoading,
            );
          },
        ),
      ),
    ).then((_) => _startHideTimer());
  }

  void _showSubtitleSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubtitleSettingsBottomSheet(
        initialOptions: _subtitleStyle,
        onSettingsChanged: (newOptions) {
          setState(() => _subtitleStyle = newOptions);
          newOptions.save();
        },
      ),
    ).then((_) => _startHideTimer());
  }

  Future<void> _saveProgress() async {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }

    final position = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;

    if (position.inSeconds < 10) {
      return;
    }

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
        subtitleLanguageCode: _currentSubtitle?.language,
        originalLanguage: widget.originalLanguage,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _saveProgress();
    _hideTimer?.cancel();
    _stopSubtitleTimer();
    _videoPlayerController?.removeListener(_onControllerUpdate);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _subtitleCubit.close();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _saveProgress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // 1. Video Player Layer
              if (_chewieController != null &&
                  _videoPlayerController!.value.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  ),
                ),

              // 2. Loading / Buffering Indicator Layer
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

              // 3. Subtitle Overlay Layer
              SubtitleOverlay(
                subtitleText: _currentSubtitleText,
                style: _subtitleStyle,
              ),

              // 4. Controls & Interaction Layer
              if (_videoPlayerController != null)
                BlocProvider.value(
                  value: _subtitleCubit,
                  child: BlocListener<SubtitleCubit, SubtitleState>(
                    listener: (context, state) {
                      if (state.selectedSubtitle != null &&
                          _currentSubtitle == null) {
                        _onSubtitleSelected(state.selectedSubtitle);
                      }
                    },
                    child: PlayerControlsOverlay(
                      controller: _videoPlayerController!,
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

              // 5. Error State Layer
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
