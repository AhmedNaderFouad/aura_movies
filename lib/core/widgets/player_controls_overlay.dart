import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final String title;
  final bool isVisible;
  final bool isInitializing;
  final VoidCallback onBack;
  final VoidCallback onShowQuality;
  final VoidCallback onShowSubtitleSettings;
  final VoidCallback onShowSubtitles;
  final VoidCallback onActionUserTap;

  const PlayerControlsOverlay({
    super.key,
    required this.controller,
    required this.title,
    required this.isVisible,
    required this.isInitializing,
    required this.onBack,
    required this.onShowQuality,
    required this.onShowSubtitleSettings,
    required this.onShowSubtitles,
    required this.onActionUserTap,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final bool isBuffering = controller.value.isBuffering || isInitializing;

    return Stack(
      children: [
        // 1. Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isVisible ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onShowQuality,
                        icon: const Icon(Icons.settings, color: Colors.white),
                        tooltip: 'Video Quality',
                      ),
                      IconButton(
                        onPressed: onShowSubtitleSettings,
                        icon: const Icon(Icons.tune, color: Colors.white),
                        tooltip: 'Subtitle Settings',
                      ),
                      IconButton(
                        onPressed: onShowSubtitles,
                        icon: const Icon(Icons.subtitles, color: Colors.white),
                        tooltip: 'Select Subtitles',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Center Hub (Strict Conditional Rendering to prevent overlap)
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Loading Spinner - Always visible during buffering, regardless of controls visibility
              if (isBuffering)
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),

              // Controls Row
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isVisible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !isVisible,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Replay 10s - Hidden during initial load
                      if (!isInitializing)
                        IconButton(
                          onPressed: () {
                            final newPos =
                                controller.value.position -
                                const Duration(seconds: 10);
                            controller.seekTo(
                              newPos < Duration.zero ? Duration.zero : newPos,
                            );
                            onActionUserTap();
                          },
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      if (!isInitializing) const SizedBox(width: 48),

                      // Center Action: Play/Pause (Hidden if buffering to show spinner instead)
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: isBuffering
                            ? const SizedBox.shrink()
                            : IconButton(
                                onPressed: () {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                  onActionUserTap();
                                },
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                      ),
                      if (!isInitializing) const SizedBox(width: 48),

                      // Forward 10s - Hidden during initial load
                      if (!isInitializing)
                        IconButton(
                          onPressed: () {
                            final newPos =
                                controller.value.position +
                                const Duration(seconds: 10);
                            controller.seekTo(newPos);
                            onActionUserTap();
                          },
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Bottom Bar & Timeline
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isVisible ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: Container(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.value.isInitialized
                                  ? "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}"
                                  : "00:00 / 00:00",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Full width Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                          activeTrackColor: Colors.red,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.red,
                          trackShape: const RectangularSliderTrackShape(),
                        ),
                        child: Slider(
                          value: controller.value.isInitialized
                              ? controller.value.position.inMilliseconds
                                    .toDouble()
                                    .clamp(
                                      0,
                                      controller.value.duration.inMilliseconds
                                          .toDouble(),
                                    )
                              : 0.0,
                          min: 0.0,
                          max: controller.value.isInitialized
                              ? controller.value.duration.inMilliseconds
                                    .toDouble()
                              : 0.0,
                          onChanged: controller.value.isInitialized
                              ? (value) {
                                  controller.seekTo(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                  onActionUserTap();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
