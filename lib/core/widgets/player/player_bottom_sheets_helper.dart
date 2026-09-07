import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/video_source_model.dart';
import '../../../features/subtitles/presentation/cubit/subtitle_cubit.dart';
import '../../../features/subtitles/presentation/widgets/subtitles_bottom_sheet.dart';
import '../../../features/subtitles/presentation/widgets/subtitle_settings_bottom_sheet.dart';
import '../quality_selection_bottom_sheet.dart';
import '../../../features/subtitles/data/models/subtitle_model.dart';
import '../../../features/subtitles/domain/entities/subtitle_style_options.dart';

class PlayerBottomSheetsHelper {
  static void showQualitySelection({
    required BuildContext context,
    required List<VideoQuality> availableQualities,
    required VideoQuality? selectedQuality,
    required Function(VideoQuality) onQualitySelected,
    required VoidCallback onDismiss,
  }) {
    if (availableQualities.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QualitySelectionBottomSheet(
        availableQualities: availableQualities,
        currentQuality: selectedQuality,
        onQualitySelected: (quality) {
          onQualitySelected(quality);
        },
      ),
    ).then((_) => onDismiss());
  }

  static void showSubtitleSelection({
    required BuildContext context,
    required SubtitleCubit subtitleCubit,
    required List<SubtitleModel> sourceSubtitles,
    required SubtitleModel? currentSubtitle,
    required Function(SubtitleModel?) onSubtitleSelected,
    required VoidCallback onDismiss,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: subtitleCubit,
        child: BlocBuilder<SubtitleCubit, SubtitleState>(
          builder: (context, state) => SubtitlesBottomSheet(
            wyzieSubtitles: [...sourceSubtitles, ...state.wyzieSubtitles],
            openSubtitles: state.openSubtitles,
            currentSubtitle: currentSubtitle,
            onSubtitleSelected: onSubtitleSelected,
            isLoading: state.isLoading,
          ),
        ),
      ),
    ).then((_) => onDismiss());
  }

  static void showSubtitleSettings({
    required BuildContext context,
    required SubtitleStyleOptions initialOptions,
    required Function(SubtitleStyleOptions) onSettingsChanged,
    required VoidCallback onDismiss,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubtitleSettingsBottomSheet(
        initialOptions: initialOptions,
        onSettingsChanged: onSettingsChanged,
      ),
    ).then((_) => onDismiss());
  }
}
