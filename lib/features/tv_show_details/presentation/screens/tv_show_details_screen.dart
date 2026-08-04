import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../core/utils/watch_now_handler.dart';
import '../cubit/tv_show_details_cubit.dart';
import '../cubit/tv_show_details_state.dart';
import '../../domain/entities/tv_show_details.dart';
import 'package:aura_movies/core/widgets/media_synopsis_widget.dart';
import 'package:aura_movies/core/widgets/shimmer_loading_widget.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:aura_movies/features/movie_details/presentation/widgets/action_buttons_widget.dart';
import 'package:aura_movies/core/widgets/custom_snackbar.dart';
import 'package:aura_movies/features/home/domain/entities/movie.dart';

class TVShowDetailsScreen extends StatefulWidget {
  final int tvShowId;

  const TVShowDetailsScreen({super.key, required this.tvShowId});

  @override
  State<TVShowDetailsScreen> createState() => _TVShowDetailsScreenState();
}

class _TVShowDetailsScreenState extends State<TVShowDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TVShowDetailsCubit>().loadTVShowDetails(widget.tvShowId);
    context.read<WatchlistCubit>().loadWatchlist();
  }

  Movie _convertToMovie(TVShowDetails details) {
    return Movie(
      id: details.id,
      title: details.name,
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
      overview: details.overview,
      voteAverage: details.voteAverage,
      releaseDate: details.firstAirDate,
      genreIds: const [],
      isTvShow: true,
    );
  }

  bool _isComingSoon(String? firstAirDate) {
    if (firstAirDate == null || firstAirDate.isEmpty) return false;
    try {
      final airDate = DateTime.parse(firstAirDate);
      return airDate.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const AppBackButton(),
        title: const CustomAppBar(),
        centerTitle: true,
      ),
      body: BlocBuilder<TVShowDetailsCubit, TVShowDetailsState>(
        builder: (context, state) {
          if (state is TVShowDetailsLoading) {
            return _buildLoadingWidget();
          } else if (state is TVShowDetailsLoaded) {
            final details = state.details;
            final isComingSoon = _isComingSoon(details.firstAirDate);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Area: Backdrop
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 280.h,
                        child: details.backdropPath != null
                            ? AppCachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w500${details.backdropPath}',
                                errorWidget:
                                    Container(color: AppColors.surface),
                              )
                            : Container(color: AppColors.surface),
                      ),
                      Container(
                        width: double.infinity,
                        height: 280.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.background.withValues(alpha: 0.1),
                              AppColors.background.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 20.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              details.voteAverage.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),

                  MediaSynopsisWidget(overview: details.overview),

                  BlocConsumer<WatchlistCubit, WatchlistState>(
                    listener: (context, state) {
                      if (state is WatchlistToggleSuccess) {
                        CustomSnackBar.show(
                          context,
                          message: state.message,
                          isError: false,
                        );
                      }
                    },
                    builder: (context, watchlistState) {
                      bool isInWatchlist = false;
                      if (watchlistState is WatchlistLoaded) {
                        isInWatchlist = watchlistState.movies
                            .any((m) => m.id == widget.tvShowId);
                      }

                      return ActionButtonsWidget(
                        isInWatchlist: isInWatchlist,
                        isComingSoon: isComingSoon,
                        showWatchNow: false,
                        onAddToWatchlistPressed: () {
                          context.read<WatchlistCubit>().toggleWatchlist(
                                _convertToMovie(details),
                              );
                        },
                      );
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        // Coming Soon Message or Episodes
                        if (isComingSoon)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 40.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
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
                                  'This show will be available on ${details.firstAirDate}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Season Selector
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Seasons',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Theme(
                                    data: Theme.of(
                                      context,
                                    ).copyWith(canvasColor: AppColors.surface),
                                    child: DropdownButton<int>(
                                      value: state.selectedSeasonNumber,
                                      dropdownColor: AppColors.surface,
                                      style: const TextStyle(color: Colors.white),
                                      underline: Container(
                                        height: 2,
                                        color: AppColors.primary,
                                      ),
                                      onChanged: (int? newValue) {
                                        if (newValue != null) {
                                          context
                                              .read<TVShowDetailsCubit>()
                                              .changeSeason(newValue);
                                        }
                                      },
                                      items: details.seasons
                                          .map<DropdownMenuItem<int>>((
                                            Season season,
                                          ) {
                                            return DropdownMenuItem<int>(
                                              value: season.seasonNumber,
                                              child: Text(season.name),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Episodes List
                              if (state.isEpisodesLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.currentSeasonEpisodes.length,
                                  itemBuilder: (context, index) {
                                    final episode =
                                        state.currentSeasonEpisodes[index];
                                    return _buildEpisodeItem(
                                      episode,
                                      state.selectedSeasonNumber,
                                    );
                                  },
                                ),
                            ],
                          ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is TVShowDetailsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (state is TVShowDetailsNoInternet) {
            return Center(
              child: NoInternetWidget(
                onRetry: () => context
                    .read<TVShowDetailsCubit>()
                    .loadTVShowDetails(widget.tvShowId),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          ShimmerLoadingWidget(
            width: double.infinity,
            height: 280.h,
            borderRadius: 0,
          ),
          SizedBox(height: 24.h),
          // Info section shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingWidget(
                  width: 250.w,
                  height: 32.h,
                  borderRadius: 4.0,
                ),
                SizedBox(height: 16.h),
                ShimmerLoadingWidget(
                  width: 100.w,
                  height: 20.h,
                  borderRadius: 4.0,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Synopsis card shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ShimmerLoadingWidget(
              width: double.infinity,
              height: 150.h,
              borderRadius: 24.0,
            ),
          ),
          SizedBox(height: 24.h),
          // Buttons shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ShimmerLoadingWidget(
              width: double.infinity,
              height: 56.h,
              borderRadius: 30.0,
            ),
          ),
          SizedBox(height: 32.h),
          // Seasons & Episodes section shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoadingWidget(
                      width: 100.w,
                      height: 24.h,
                      borderRadius: 4.0,
                    ),
                    ShimmerLoadingWidget(
                      width: 120.w,
                      height: 36.h,
                      borderRadius: 8.0,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Shimmer Episode items
                ...List.generate(3, (index) => _buildShimmerEpisodeItem()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEpisodeItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ShimmerLoadingWidget(
            width: 120.w,
            height: 80.h,
            borderRadius: 8.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingWidget(
                  width: 150.w,
                  height: 16.h,
                  borderRadius: 4.r,
                ),
                SizedBox(height: 12.h),
                ShimmerLoadingWidget(
                  width: 80.w,
                  height: 32.h,
                  borderRadius: 12.r,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(Episode episode, int seasonNumber) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Episode Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 120.w,
              height: 80.h,
              child: episode.stillPath != null
                  ? AppCachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w300${episode.stillPath}',
                      errorWidget: Container(color: Colors.black),
                    )
                  : Container(color: Colors.black),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E${episode.episodeNumber}. ${episode.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                ElevatedButton.icon(
                  onPressed: () {
                    WatchNowHandler.handleWatchNow(
                      context: context,
                      tmdbId: widget.tvShowId.toString(),
                      title: episode.name,
                      isTvShow: true,
                      season: seasonNumber,
                      episode: episode.episodeNumber,
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    textStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
