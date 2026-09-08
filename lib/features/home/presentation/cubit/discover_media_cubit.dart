import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/tmdb_ids_config.dart';
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

  /// Determines if a brand ID refers to a streaming watch provider.
  /// Watch providers are used with with_watch_providers parameter for streaming availability.
  bool _isStreamingProvider(BrandEntity brand) {
    if (!brand.isNetwork) return false;

    // Check if the network ID matches any known streaming platform TV network IDs
    final networkId = brand.networkId;
    if (networkId == null) return false;

    return TvNetworkIds.all.containsKey(networkId);
  }

  /// Determines if a brand ID refers to a production company.
  bool _isProductionCompany(BrandEntity brand) {
    if (brand.isNetwork) return false;

    final companyId = brand.companyId;
    if (companyId == null) return false;

    return ProductionCompanyIds.isValid(companyId);
  }

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

      // Determine the type of filtering to use based on brand properties
      final isStreaming = _isStreamingProvider(brand);
      final isCompany = _isProductionCompany(brand);

      if (_isMovie) {
        // For movies, determine which parameter to use
        if (isStreaming) {
          // Streaming platform: use watch provider ID
          final watchProviderId = WatchProviderIds.getProviderIdForName(
            brand.name,
          );
          newMedia = await discoverMoviesUseCase.execute(
            page: _currentPage,
            watchProviderIds: watchProviderId.isNotEmpty
                ? watchProviderId
                : null,
          );
        } else if (isCompany) {
          // Production company: use company ID
          newMedia = await discoverMoviesUseCase.execute(
            page: _currentPage,
            companyId: brand.companyId,
          );
        } else {
          // Fallback for unknown types
          newMedia = await discoverMoviesUseCase.execute(
            page: _currentPage,
            companyId: brand.companyId,
          );
        }
      } else {
        // For TV shows, use appropriate parameter based on type
        if (isStreaming) {
          // For streaming platforms on TV, use watch provider ID
          final watchProviderId = WatchProviderIds.getProviderIdForName(
            brand.name,
          );
          newMedia = await discoverTvShowsUseCase.execute(
            page: _currentPage,
            watchProviderIds: watchProviderId.isNotEmpty
                ? watchProviderId
                : null,
          );
        } else if (isCompany) {
          // Production company on TV: use company ID
          newMedia = await discoverTvShowsUseCase.execute(
            page: _currentPage,
            companyId: brand.companyId,
          );
        } else {
          // For general networks/brands, try using network ID
          newMedia = await discoverTvShowsUseCase.execute(
            page: _currentPage,
            networkId: brand.networkId,
            companyId: brand.companyId,
          );
        }
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
