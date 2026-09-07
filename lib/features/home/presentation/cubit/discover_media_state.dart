import 'package:equatable/equatable.dart';

abstract class DiscoverMediaState extends Equatable {
  const DiscoverMediaState();

  @override
  List<Object?> get props => [];
}

class DiscoverMediaInitial extends DiscoverMediaState {}

class DiscoverMediaLoading extends DiscoverMediaState {
  final bool isFirstFetch;
  final List<dynamic> oldMedia;
  const DiscoverMediaLoading({
    this.isFirstFetch = true,
    this.oldMedia = const [],
  });

  @override
  List<Object?> get props => [isFirstFetch, oldMedia];
}

class DiscoverMediaSuccess extends DiscoverMediaState {
  final List<dynamic> media;
  final bool hasReachedMax;
  final int currentPage;

  const DiscoverMediaSuccess({
    required this.media,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  DiscoverMediaSuccess copyWith({
    List<dynamic>? media,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return DiscoverMediaSuccess(
      media: media ?? this.media,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [media, hasReachedMax, currentPage];
}

class DiscoverMediaError extends DiscoverMediaState {
  final String message;
  const DiscoverMediaError(this.message);

  @override
  List<Object?> get props => [message];
}
