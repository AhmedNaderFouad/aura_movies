part of 'subtitle_cubit.dart';

class SubtitleState extends Equatable {
  final List<SubtitleModel> wyzieSubtitles;
  final List<SubtitleModel> openSubtitles;
  final SubtitleModel? selectedSubtitle;
  final bool isLoading;
  final String? error;

  const SubtitleState({
    this.wyzieSubtitles = const [],
    this.openSubtitles = const [],
    this.selectedSubtitle, // Default to null (OFF)
    this.isLoading = false,
    this.error,
  });

  SubtitleState copyWith({
    List<SubtitleModel>? wyzieSubtitles,
    List<SubtitleModel>? openSubtitles,
    SubtitleModel? Function()? selectedSubtitle,
    bool? isLoading,
    String? error,
  }) {
    return SubtitleState(
      wyzieSubtitles: wyzieSubtitles ?? this.wyzieSubtitles,
      openSubtitles: openSubtitles ?? this.openSubtitles,
      selectedSubtitle:
          selectedSubtitle != null ? selectedSubtitle() : this.selectedSubtitle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    wyzieSubtitles,
    openSubtitles,
    selectedSubtitle,
    isLoading,
    error,
  ];
}
