import 'package:flutter/material.dart';
import '../../../features/subtitles/domain/entities/subtitle_style_options.dart';

class SubtitleOverlay extends StatelessWidget {
  final String subtitleText;
  final SubtitleStyleOptions style;

  const SubtitleOverlay({
    super.key,
    required this.subtitleText,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitleText.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: style.bottomPadding,
      left: 40,
      right: 40,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: style.backgroundOpacity),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.textColor,
                fontSize: style.fontSize,
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
    );
  }
}
