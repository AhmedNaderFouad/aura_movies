import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/widgets/custom_app_bar.dart';
import 'package:aura_movies/core/widgets/app_back_button.dart';
import 'package:aura_movies/core/widgets/custom_snackbar.dart';
import '../widgets/media_synopsis_widget.dart';
import '../widgets/media_details_shimmer_view.dart';
import 'package:aura_movies/core/widgets/no_internet_widget.dart';
import 'package:aura_movies/core/utils/watch_now_handler.dart';
import 'package:aura_movies/core/constants/media_type.dart';
import 'package:aura_movies/features/home/domain/entities/movie.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_state.dart';
import '../cubit/media_details_cubit.dart';
import '../cubit/media_details_state.dart';
import '../widgets/media_details_header_widget.dart';
import '../widgets/media_info_section_widget.dart';
import '../widgets/media_action_buttons_widget.dart';
import '../widgets/media_cast_section_widget.dart';
import '../widgets/media_recommendations_section_widget.dart';
import '../widgets/media_details_info_widget.dart';
import '../widgets/tv_show_episodes_widget.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_credits.dart';

class MediaDetailsScreen extends StatefulWidget {
  final int mediaId;
  final MediaType mediaType;

  const MediaDetailsScreen({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  @override
  State<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends State<MediaDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MediaDetailsCubit>().loadMediaDetails(
      widget.mediaId,
      widget.mediaType,
    );
    context.read<WatchlistCubit>().loadWatchlist();
  }

  Movie _convertToMovie(MediaDetails details) {
    return Movie(
      id: details.id,
      title: details.title,
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
      overview: details.overview,
      voteAverage: details.voteAverage,
      releaseDate: details.releaseDate,
      genreIds: details.genres.map((g) => g.id).toList(),
      isTvShow: details.isTvShow,
    );
  }

  bool _isComingSoon(String? date) {
    if (date == null || date.isEmpty) return false;
    try {
      final releaseDate = DateTime.parse(date);
      return releaseDate.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const AppBackButton(),
        title: const CustomAppBar(),
        centerTitle: true,
      ),
      body: BlocBuilder<MediaDetailsCubit, MediaDetailsState>(
        builder: (context, state) {
          if (state is MediaDetailsLoading) {
            return MediaDetailsShimmerView(mediaType: widget.mediaType);
          } else if (state is MediaDetailsLoaded) {
            final details = state.details;
            final credits = state.credits;
            final isComingSoon = _isComingSoon(details.releaseDate);

            MediaCrewMember? director;
            if (credits != null && credits.crew.isNotEmpty) {
              final directors = credits.crew.where(
                (member) =>
                    member.job == 'Director' || member.job == 'Producer',
              );
              if (directors.isNotEmpty) {
                director = directors.first;
              }
            }

            final watchlistSection =
                BlocConsumer<WatchlistCubit, WatchlistState>(
                  listener: (context, watchlistState) {
                    if (watchlistState is WatchlistToggleSuccess) {
                      CustomSnackBar.show(
                        context,
                        message: watchlistState.message,
                        isError: false,
                      );
                    }
                  },
                  builder: (context, watchlistState) {
                    bool isInWatchlist = false;
                    if (watchlistState is WatchlistLoaded) {
                      isInWatchlist = watchlistState.movies.any(
                        (m) => m.id == widget.mediaId,
                      );
                    }

                    return MediaActionButtonsWidget(
                      isInWatchlist: isInWatchlist,
                      isComingSoon: isComingSoon,
                      showWatchNow: !details.isTvShow,
                      onWatchNowPressed: () {
                        WatchNowHandler.handleWatchNow(
                          context: context,
                          tmdbId: details.id.toString(),
                          imdbId: details.imdbId,
                          title: details.title,
                          posterPath: details.posterPath,
                          isTvShow: false,
                          originalLanguage: details.originalLanguage,
                        );
                      },
                      onAddToWatchlistPressed: () {
                        context.read<WatchlistCubit>().toggleWatchlist(
                          _convertToMovie(details),
                        );
                      },
                    );
                  },
                );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaDetailsHeaderWidget(mediaDetails: details),
                  SizedBox(height: 10.h),
                  MediaInfoSectionWidget(mediaDetails: details),
                  if (!details.isTvShow) SizedBox(height: 12.h),
                  if (details.isTvShow) ...[
                    MediaSynopsisWidget(
                      tagline: details.tagline,
                      overview: details.overview,
                    ),
                    watchlistSection,
                    if (isComingSoon)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildComingSoonPlaceholder(details.releaseDate),
                      )
                    else
                      TVShowEpisodesWidget(
                        details: details,
                        currentSeasonEpisodes: state.currentSeasonEpisodes,
                        selectedSeasonNumber: state.selectedSeasonNumber,
                        isEpisodesLoading: state.isEpisodesLoading,
                        onSeasonChanged: (seasonNumber) => context
                            .read<MediaDetailsCubit>()
                            .changeSeason(seasonNumber),
                      ),
                  ] else ...[
                    watchlistSection,
                    SizedBox(height: 16.h),
                    MediaSynopsisWidget(
                      tagline: details.tagline,
                      overview: details.overview,
                    ),
                  ],
                  if (credits != null && credits.cast.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    MediaCastSectionWidget(cast: credits.cast),
                  ],
                  SizedBox(height: 16.h),
                  MediaRecommendationsSectionWidget(
                    recommendations: state.recommendations,
                    isTvShow: details.isTvShow,
                  ),
                  SizedBox(height: 12.h),
                  MediaDetailsInfoWidget(
                    mediaDetails: details,
                    director: director,
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            );
          } else if (state is MediaDetailsError) {
            return _buildErrorWidget(state.message);
          } else if (state is MediaDetailsNoInternet) {
            return Center(
              child: NoInternetWidget(
                onRetry: () => context
                    .read<MediaDetailsCubit>()
                    .loadMediaDetails(widget.mediaId, widget.mediaType),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildComingSoonPlaceholder(String? releaseDate) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48.r,
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This show will be available on $releaseDate',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.primary, size: 64.sp),
          SizedBox(height: 16.h),
          Text(
            'Error loading details',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.read<MediaDetailsCubit>().loadMediaDetails(
              widget.mediaId,
              widget.mediaType,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
