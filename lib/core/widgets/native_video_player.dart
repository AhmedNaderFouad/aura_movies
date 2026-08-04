import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/video_source_model.dart';
import '../models/watch_media_model.dart';
import '../services/watch_history_service.dart';
import '../../features/subtitles/domain/entities/subtitle_style_options.dart';
import '../../features/subtitles/data/datasources/wyzie_subtitle_service.dart';
import '../../features/subtitles/data/datasources/open_subtitles_service.dart';
import '../../features/subtitles/data/datasources/subtitle_parser.dart';
import '../../features/subtitles/data/models/subtitle_model.dart';
import '../../features/subtitles/presentation/cubit/subtitle_cubit.dart';
import '../../features/subtitles/data/repositories/subtitle_repository_impl.dart';
import '../../features/subtitles/presentation/widgets/subtitles_bottom_sheet.dart';
import '../../features/subtitles/presentation/widgets/subtitle_settings_bottom_sheet.dart';
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
  final Duration? startPosition;
  final String? initialSubtitle;

  const NativeVideoPlayer({
    super.key,
    required this.source,
    required this.title,
    required this.mediaId,
    required this.mediaType,
    this.posterPath,
    this.seasonNumber,
    this.episodeNumber,
    this.startPosition,
    this.initialSubtitle,
  });

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final WatchHistoryService _watchHistoryService = WatchHistoryService();

  bool _hasError = false;
  bool _isInitializing = true;
  bool _showControls = false;
  bool _isBuffering = false;
  Timer? _hideTimer;

  SubtitleModel? _currentSubtitle;
  List<SubtitleCue> _subtitleCues = [];
  String _currentSubtitleText = '';
  SubtitleStyleOptions _subtitleStyle = const SubtitleStyleOptions();

  late SubtitleCubit _subtitleCubit;

  List<VideoQuality> _availableQualities = [];
  VideoQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    _subtitleCubit = SubtitleCubit(
      SubtitleRepositoryImpl(
        wyzieService: SubtitleService(),
        openSubtitlesService: OpenSubtitlesService(),
      ),
    );
    WakelockPlus.enable();
    _setFullScreen();
    _loadSubtitleSettings();
    _initializePlayer(startAt: widget.startPosition);
    _fetchSubtitles();
  }

  void _fetchSubtitles() {
    _subtitleCubit.fetchSubtitles(
      tmdbId: widget.mediaId.toString(),
      isTv: widget.mediaType == 'tv',
      season: widget.seasonNumber,
      episode: widget.episodeNumber,
    );
  }

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
      setState(() {
        _subtitleStyle = savedOptions;
      });
    }
  }

  Map<String, String> _getHeaders(String url) {
    final Map<String, String> headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    };

    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('vidsrc')) {
      headers['Referer'] = 'https://vidsrc.pm/';
      headers['Origin'] = 'https://vidsrc.pm';
    }
    return headers;
  }

  Future<void> _initializePlayer({
    String? specificUrl,
    Duration? startAt,
  }) async {
    final url = specificUrl ?? widget.source.hlsUrl;

    if (url == null || url.isEmpty) {
      setState(() {
        _hasError = true;
        _isInitializing = false;
      });
      return;
    }

    // Load qualities if not already loaded (only for the initial master URL)
    if (_availableQualities.isEmpty && specificUrl == null) {
      _loadQualities(url);
    }

    try {
      // Clean up existing controllers if switching quality
      if (specificUrl != null) {
        final oldVideoController = _videoPlayerController;
        final oldChewieController = _chewieController;

        _videoPlayerController?.removeListener(_onControllerUpdate);

        oldVideoController?.dispose();
        oldChewieController?.dispose();
      }

      final headers = {...widget.source.headers, ..._getHeaders(url)};

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers,
      );

      await _videoPlayerController!.initialize();

      if (startAt != null) {
        await _videoPlayerController!.seekTo(startAt);
      }

      // Handle initial subtitle
      if (widget.initialSubtitle != null) {
        final initialSub = widget.source.subtitles.firstWhere(
          (s) => s.language == widget.initialSubtitle,
          orElse: () => SubtitleModel(),
        );
        if (initialSub.url != null) {
          _onSubtitleSelected(initialSub);
        }
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: false, // We build our own exact replica controls
        showOptions: false, // Disable default popup menu
        placeholder: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorBuilder: (context, errorMessage) {
          return PlayerErrorWidget(
            onRetry: () {
              _initializePlayer(specificUrl: specificUrl, startAt: startAt);
            },
          );
        },
      );

      _videoPlayerController!.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
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
    final List<VideoQuality> qualities = [
      VideoQuality(label: 'Auto (Recommended)', url: masterUrl, isAuto: true),
    ];

    try {
      final headers = _getHeaders(masterUrl);
      final response = await Dio().get(
        masterUrl,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final content = response.data.toString();
        final lines = content.split('\n');
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('#EXT-X-STREAM-INF:')) {
            String label = 'Unknown';
            final resMatch = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
            if (resMatch != null) {
              final res = resMatch.group(1)!;
              final height = res.split('x')[1];
              label = '${height}p';
            }

            // Find the next non-empty line that doesn't start with #
            String? variantUrl;
            for (int j = i + 1; j < lines.length; j++) {
              final nextLine = lines[j].trim();
              if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
                variantUrl = nextLine;
                break;
              }
            }

            if (variantUrl != null) {
              if (!variantUrl.startsWith('http')) {
                final uri = Uri.parse(masterUrl);
                variantUrl = uri.resolve(variantUrl).toString();
              }

              if (!qualities.any((q) => q.label == label)) {
                qualities.add(VideoQuality(label: label, url: variantUrl));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading qualities: $e');
    }

    if (mounted) {
      setState(() {
        _availableQualities = qualities;
        _selectedQuality ??= qualities.first;
      });
    }
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
          if (_selectedQuality?.url == quality.url) return;

          final currentPos =
              _videoPlayerController?.value.position ?? Duration.zero;

          setState(() {
            _selectedQuality = quality;
            _isInitializing = true;
          });

          _initializePlayer(specificUrl: quality.url, startAt: currentPos);
        },
      ),
    ).then((_) => _startHideTimer());
  }

  void _onControllerUpdate() {
    if (!mounted || _videoPlayerController == null) return;

    if (_videoPlayerController!.value.hasError) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    if (_subtitleCues.isNotEmpty) {
      final position = _videoPlayerController!.value.position;
      final currentCue = _subtitleCues.lastWhere(
        (cue) => position >= cue.start && position <= cue.end,
        orElse: () =>
            SubtitleCue(start: Duration.zero, end: Duration.zero, text: ''),
      );

      if (_currentSubtitleText != currentCue.text) {
        setState(() {
          _currentSubtitleText = currentCue.text;
        });
      }
    }

    // Refresh UI for position/duration or buffering state changes
    final currentBuffering = _videoPlayerController!.value.isBuffering;
    if (_showControls || currentBuffering != _isBuffering) {
      _isBuffering = currentBuffering;
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
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
        debugPrint(
          'NativeVideoPlayer: Getting OpenSubtitles download link for fileId: ${subtitle.fileId}',
        );
        final downloadUrl = await _subtitleCubit.getOpenSubtitlesUrl(
          subtitle.fileId!,
        );

        if (downloadUrl != null) {
          url = downloadUrl;
        } else if (url != null) {
          debugPrint(
            'NativeVideoPlayer: Download endpoint failed or quota reached, using search fallback URL: $url',
          );
        }
      }

      if (url == null) {
        debugPrint('NativeVideoPlayer: Failed to obtain subtitle URL');
        return;
      }

      debugPrint('NativeVideoPlayer: Downloading subtitle from: $url');
      final response = await Dio().get(
        url,
        options: Options(headers: {'User-Agent': 'AuraMovies v1.0.0'}),
      );

      if (response.statusCode == 200) {
        final content = response.data.toString();
        debugPrint(
          'NativeVideoPlayer: Subtitle downloaded, length: ${content.length}',
        );
        final cues = SubtitleParser.parse(content);

        if (cues.isEmpty) {
          debugPrint('NativeVideoPlayer: Failed to parse subtitle cues');
          return;
        }

        setState(() {
          _currentSubtitle = subtitle;
          _subtitleCues = cues;
        });
        _subtitleCubit.selectSubtitle(subtitle);
      } else {
        debugPrint(
          'NativeVideoPlayer: Failed to download subtitle. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error loading subtitle: $e');
    }
    _startHideTimer();
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
            // Combine built-in subtitles with Wyzie
            final allWyzie = [
              ...widget.source.subtitles,
              ...state.wyzieSubtitles,
            ];

            return SubtitlesBottomSheet(
              wyzieSubtitles: allWyzie,
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

    // Only save if we watched at least 10 seconds or 1%
    if (position.inSeconds < 10) return;

    final media = WatchMediaModel(
      id: widget.mediaId,
      title: widget.title,
      posterPath: widget.posterPath,
      mediaType: widget.mediaType,
      lastPositionMs: position.inMilliseconds,
      totalDurationMs: duration.inMilliseconds,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
      subtitleLanguageCode: _currentSubtitle?.language,
      updatedAt: DateTime.now(),
    );

    await _watchHistoryService.saveProgress(media);
  }

  @override
  void dispose() {
    _saveProgress();
    _hideTimer?.cancel();
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
        if (didPop) {
          _saveProgress();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Video Player
              if (_chewieController != null &&
                  _videoPlayerController!.value.isInitialized)
                Center(child: Chewie(controller: _chewieController!)),

              // Custom Subtitle Overlay
              if (_currentSubtitleText.isNotEmpty)
                Positioned(
                  bottom: _subtitleStyle.bottomPadding,
                  left: 40,
                  right: 40,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: _subtitleStyle.backgroundOpacity,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentSubtitleText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _subtitleStyle.textColor,
                            fontSize: _subtitleStyle.fontSize,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Unified Controls & Center Hub
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

              // Main Error State
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
