import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../search/domain/usecases/discover_movies_usecase.dart';
import '../../../search/domain/usecases/discover_tv_shows_usecase.dart';
import '../../domain/entities/brand_entity.dart';
import 'discover_media_state.dart';

class DiscoverMediaCubit extends Cubit<DiscoverMediaState> {
  final DiscoverMoviesUseCase discoverMoviesUseCase;
  final DiscoverTvShowsUseCase discoverTvShowsUseCase;

  DiscoverMediaCubit({
    required this.discoverMoviesUseCase,
    required this.discoverTvShowsUseCase,
  }) : super(DiscoverMediaInitial());

  int _currentPage = 1;
  bool _isMovie = true;
  BrandEntity? _currentBrand;

  Future<void> loadMedia(
    BrandEntity brand, {
    bool isMovie = true,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPage = 1;
      emit(const DiscoverMediaLoading(isFirstFetch: true));
    } else if (state is DiscoverMediaSuccess &&
        (state as DiscoverMediaSuccess).hasReachedMax) {
      return;
    } else if (state is DiscoverMediaLoading) {
      return;
    }

    _isMovie = isMovie;
    _currentBrand = brand;

    if (_currentPage > 1 && state is DiscoverMediaSuccess) {
      emit(
        DiscoverMediaLoading(
          isFirstFetch: false,
          oldMedia: (state as DiscoverMediaSuccess).media,
        ),
      );
    } else if (isRefresh || state is DiscoverMediaInitial) {
      emit(const DiscoverMediaLoading(isFirstFetch: true));
    }

    try {
      List<dynamic> newMedia;
      if (_isMovie) {
        newMedia = await discoverMoviesUseCase.execute(
          page: _currentPage,
          companyId: brand.companyId ?? brand.networkId,
        );
      } else {
        newMedia = await discoverTvShowsUseCase.execute(
          page: _currentPage,
          networkId: brand.isNetwork ? brand.networkId : null,
          companyId: !brand.isNetwork ? brand.companyId : null,
        );
      }

      final List<dynamic> currentMedia = (state is DiscoverMediaLoading)
          ? (state as DiscoverMediaLoading).oldMedia
          : (state is DiscoverMediaSuccess)
          ? (state as DiscoverMediaSuccess).media
          : [];

      emit(
        DiscoverMediaSuccess(
          media: isRefresh
              ? newMedia
              : (List.from(currentMedia)..addAll(newMedia)),
          hasReachedMax: newMedia.isEmpty,
          currentPage: _currentPage,
        ),
      );

      if (newMedia.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      emit(DiscoverMediaError(e.toString()));
    }
  }

  void toggleMediaType(bool isMovie) {
    if (_currentBrand != null) {
      loadMedia(_currentBrand!, isMovie: isMovie, isRefresh: true);
    }
  }
}
