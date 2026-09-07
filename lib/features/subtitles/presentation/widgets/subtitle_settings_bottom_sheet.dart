import 'package:flutter/material.dart';
import '../../domain/entities/subtitle_style_options.dart';

class SubtitleSettingsBottomSheet extends StatefulWidget {
  final SubtitleStyleOptions initialOptions;
  final ValueChanged<SubtitleStyleOptions> onSettingsChanged;

  const SubtitleSettingsBottomSheet({
    super.key,
    required this.initialOptions,
    required this.onSettingsChanged,
  });

  @override
  State<SubtitleSettingsBottomSheet> createState() =>
      _SubtitleSettingsBottomSheetState();
}

class _SubtitleSettingsBottomSheetState
    extends State<SubtitleSettingsBottomSheet> {
  late SubtitleStyleOptions _currentOptions;
  String? _activeDraggingSliderId;

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.initialOptions;
  }

  void _updateOptions(SubtitleStyleOptions newOptions) {
    setState(() {
      _currentOptions = newOptions;
    });
    widget.onSettingsChanged(newOptions);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDragging = _activeDraggingSliderId != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1C1C1E,
        ).withValues(alpha: isDragging ? 0.0 : 1.0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and Title
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isDragging ? 0.0 : 1.0,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          'Subtitle Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSettingRow(
                id: 'fontSize',
                label: 'Font Size',
                value: _currentOptions.fontSize.toInt().toString(),
                slider: Slider(
                  value: _currentOptions.fontSize,
                  min: 12,
                  max: 48,
                  onChangeStart: (_) =>
                      setState(() => _activeDraggingSliderId = 'fontSize'),
                  onChangeEnd: (_) =>
                      setState(() => _activeDraggingSliderId = null),
                  onChanged: (val) =>
                      _updateOptions(_currentOptions.copyWith(fontSize: val)),
                ),
              ),

              _buildSettingRow(
                id: 'bottomPadding',
                label: 'Bottom Padding',
                value: _currentOptions.bottomPadding.toInt().toString(),
                slider: Slider(
                  value: _currentOptions.bottomPadding,
                  min: 0,
                  max: 100,
                  onChangeStart: (_) =>
                      setState(() => _activeDraggingSliderId = 'bottomPadding'),
                  onChangeEnd: (_) =>
                      setState(() => _activeDraggingSliderId = null),
                  onChanged: (val) => _updateOptions(
                    _currentOptions.copyWith(bottomPadding: val),
                  ),
                ),
              ),

              _buildSettingRow(
                id: 'backgroundOpacity',
                label: 'Background Opacity',
                value: '${(_currentOptions.backgroundOpacity * 100).toInt()}%',
                slider: Slider(
                  value: _currentOptions.backgroundOpacity,
                  min: 0,
                  max: 1,
                  onChangeStart: (_) => setState(
                    () => _activeDraggingSliderId = 'backgroundOpacity',
                  ),
                  onChangeEnd: (_) =>
                      setState(() => _activeDraggingSliderId = null),
                  onChanged: (val) => _updateOptions(
                    _currentOptions.copyWith(backgroundOpacity: val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String id,
    required String label,
    required String value,
    required Widget slider,
  }) {
    final bool isDragging = _activeDraggingSliderId != null;
    final bool isThisSliderActive = _activeDraggingSliderId == id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDragging ? 0.0 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDragging ? (isThisSliderActive ? 0.4 : 0.0) : 1.0,
          child: slider,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
