import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/video_source_model.dart';
import 'dart:async';

class NativeVideoPlayer extends StatefulWidget {
  final List<VideoSource> sources;
  final String title;

  const NativeVideoPlayer({
    super.key,
    required this.sources,
    required this.title,
  });

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  late final Player player = Player();
  
  late final VideoController controller = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      enableHardwareAcceleration: true,
    ),
  );

  int _currentSourceIndex = 0;
  bool _hasError = false;
  bool _isInitializing = true;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _tracksSubscription;

  SubtitleTrack _currentSelectedTrack = SubtitleTrack.no();

  @override
  void initState() {
    super.initState();
    // Force Landscape orientation on entry
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system bars for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _errorSubscription = player.stream.error.listen((error) {
      debugPrint('MediaKit Error: $error');
      _handlePlaybackError();
    });

    _tracksSubscription = player.stream.tracks.listen((tracks) {
      if (mounted) {
        setState(() {
          _currentSelectedTrack = player.state.track.subtitle;
        });
      }
    });

    _initializePlayer();
  }

  Map<String, String> _getHeaders(String url) {
    final Map<String, String> headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    };

    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('vidsrc') ||
        lowerUrl.contains('scalablecontentengine')) {
      headers['Referer'] = 'https://vidsrc.pm/';
      headers['Origin'] = 'https://vidsrc.pm';
    } else if (lowerUrl.contains('vidlink')) {
      headers['Referer'] = 'https://vidlink.pro/';
    }

    return headers;
  }

  Future<void> _initializePlayer() async {
    if (_currentSourceIndex >= widget.sources.length) {
      setState(() {
        _hasError = true;
        _isInitializing = false;
      });
      return;
    }

    final source = widget.sources[_currentSourceIndex];
    debugPrint('Initializing player with source: ${source.name}');

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    final url = source.hlsUrl;

    if (url == null || url.isEmpty) {
      _currentSourceIndex++;
      _initializePlayer();
      return;
    }

    try {
      final dynamicHeaders = _getHeaders(url);
      final headers = {...source.headers, ...dynamicHeaders};

      _currentSelectedTrack = SubtitleTrack.no();

      await player.open(Media(url, httpHeaders: headers), play: true);

      if (source.subtitles.isNotEmpty) {
        final firstValidSubtitle = source.subtitles.firstWhere(
          (s) => s.url != null && s.url!.isNotEmpty,
          orElse: () => source.subtitles.first,
        );
        
        if (firstValidSubtitle.url != null) {
          final track = SubtitleTrack.uri(
            firstValidSubtitle.url!,
            title: firstValidSubtitle.language ?? 'Default',
            language: firstValidSubtitle.language,
          );
          player.setSubtitleTrack(track);
          setState(() => _currentSelectedTrack = track);
        }
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing source $_currentSourceIndex ($url): $e');
      _handlePlaybackError();
    }
  }

  void _handlePlaybackError() {
    if (!mounted) return;
    _currentSourceIndex++;
    _initializePlayer();
  }

  void _showSubtitleSelection() {
    final source = widget.sources[_currentSourceIndex];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final embeddedTracks = player.state.tracks.subtitle.where(
              (t) => t.id != 'no' && t.id != 'auto'
            ).toList();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                bottom: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Title
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Subtitles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      // List
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _buildTrackTile(
                              context,
                              'Off',
                              SubtitleTrack.no(),
                              isSelected: _currentSelectedTrack.id == 'no',
                            ),
                            if (source.subtitles.isNotEmpty) ...[
                              _buildSectionHeader('EXTERNAL'),
                              ...source.subtitles.where((s) => s.url != null).map((s) {
                                final track = SubtitleTrack.uri(
                                  s.url!,
                                  title: s.language ?? 'Unknown',
                                  language: s.language,
                                );
                                final bool isSelected = _currentSelectedTrack.id == track.id || 
                                                       (_currentSelectedTrack.title == track.title && track.id != 'no');
                                return _buildTrackTile(
                                  context,
                                  s.language ?? 'Unknown',
                                  track,
                                  isSelected: isSelected,
                                );
                              }),
                            ],
                            if (embeddedTracks.isNotEmpty) ...[
                              _buildSectionHeader('EMBEDDED'),
                              ...embeddedTracks.map((t) {
                                final title = t.title ?? t.language ?? 'Track ${t.id}';
                                return _buildTrackTile(
                                  context,
                                  title,
                                  t,
                                  isSelected: _currentSelectedTrack.id == t.id,
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTrackTile(BuildContext context, String title, SubtitleTrack track, {required bool isSelected}) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        player.setSubtitleTrack(track);
        setState(() {
          _currentSelectedTrack = track;
        });
        Navigator.pop(context);
      },
      leading: Icon(
        Icons.check,
        size: 18,
        color: isSelected ? Colors.blue : Colors.transparent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white70,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Reset to Portrait orientation on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Restore system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _errorSubscription?.cancel();
    _tracksSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlsTheme = MaterialVideoControlsThemeData(
      visibleOnMount: true,
      controlsHoverDuration: const Duration(seconds: 3),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      topButtonBar: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0)),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: _showSubtitleSelection,
          icon: const Icon(Icons.subtitles, color: Colors.white),
          tooltip: 'Subtitles',
        ),
      ],
      primaryButtonBar: [
        const Spacer(flex: 3),
        IconButton(
          onPressed: () => player.seek(player.state.position - const Duration(seconds: 10)),
          icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Rewind 10s',
        ),
        const SizedBox(width: 40),
        // Custom Play/Pause Button in a circle
        StreamBuilder<bool>(
          stream: player.stream.playing,
          builder: (context, snapshot) {
            final playing = snapshot.data ?? player.state.playing;
            return Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: player.playOrPause,
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 40),
        IconButton(
          onPressed: () => player.seek(player.state.position + const Duration(seconds: 10)),
          icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
          padding: EdgeInsets.zero,
          tooltip: 'Forward 10s',
        ),
        const Spacer(flex: 3),
      ],
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        const MaterialFullscreenButton(),
      ],
      seekBarColor: Colors.white24,
      seekBarBufferColor: Colors.white54,
      seekBarPositionColor: Colors.red,
      seekBarThumbColor: Colors.red,
      seekBarThumbSize: 12,
      seekBarHeight: 4,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: MaterialVideoControlsTheme(
        normal: controlsTheme,
        fullscreen: controlsTheme,
        child: Stack(
          children: [
            if (_isInitializing)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text("Loading source...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            else if (_hasError)
              _buildErrorWidget()
            else ...[
              Positioned.fill(
                child: Video(
                  controller: controller,
                  controls: MaterialVideoControls,
                  fit: BoxFit.contain,
                  subtitleViewConfiguration: const SubtitleViewConfiguration(
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      backgroundColor: Colors.black45,
                    ),
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                ),
              ),
              // Background Dimming Gradient behind controls
              IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black54,
                      ],
                      stops: [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text("Failed to load video from all sources", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _currentSourceIndex = 0;
              _initializePlayer();
            },
            child: const Text("Retry All Sources", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
