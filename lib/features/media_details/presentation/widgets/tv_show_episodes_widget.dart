import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/widgets/app_cached_network_image.dart';
import 'package:aura_movies/core/widgets/shimmer_loading_widget.dart';
import 'package:aura_movies/core/utils/watch_now_handler.dart';
import '../../domain/entities/media_details.dart';

class TVShowEpisodesWidget extends StatelessWidget {
  final MediaDetails details;
  final List<MediaEpisode> currentSeasonEpisodes;
  final int selectedSeasonNumber;
  final bool isEpisodesLoading;
  final Function(int) onSeasonChanged;

  const TVShowEpisodesWidget({
    super.key,
    required this.details,
    required this.currentSeasonEpisodes,
    required this.selectedSeasonNumber,
    required this.isEpisodesLoading,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!details.isTvShow) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        // Horizontal Season Selector
        SizedBox(
          height: 45.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: details.seasons.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) {
              final season = details.seasons[index];
              final isSelected = season.seasonNumber == selectedSeasonNumber;
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () => onSeasonChanged(season.seasonNumber),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white10,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      season.name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24.h),
        // Episodes List with horizontal padding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: isEpisodesLoading
              ? Builder(
                  builder: (context) {
                    final seasons = details.seasons.where(
                      (s) => s.seasonNumber == selectedSeasonNumber,
                    );
                    final currentSeason = seasons.isNotEmpty
                        ? seasons.first
                        : details.seasons.first;

                    return Column(
                      children: List.generate(
                        currentSeason.episodeCount > 0
                            ? currentSeason.episodeCount
                            : 3,
                        (index) => _buildShimmerEpisodeItem(),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentSeasonEpisodes.length,
                  itemBuilder: (context, index) {
                    final episode = currentSeasonEpisodes[index];
                    return _buildEpisodeItem(context, episode);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShimmerEpisodeItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Stack(
        children: [
          ShimmerLoadingWidget(
            width: double.infinity,
            height: 110.h,
            borderRadius: 16.r,
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130.w,
                  height: 85.h,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 100.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(BuildContext context, MediaEpisode episode) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode Thumbnail with Play Overlay
          GestureDetector(
            onTap: () => _playEpisode(context, episode),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130.w,
                    height: 85.h,
                    child: episode.stillPath != null
                        ? AppCachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w300${episode.stillPath}',
                            placeholder: Container(color: Colors.black26),
                            errorWidget: Container(color: Colors.black),
                          )
                        : Container(color: Colors.black),
                  ),
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 24.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
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
                SizedBox(height: 6.h),
                Text(
                  episode.overview,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playEpisode(BuildContext context, MediaEpisode episode) {
    WatchNowHandler.handleWatchNow(
      context: context,
      tmdbId: details.id.toString(),
      title: episode.name,
      posterPath: details.posterPath,
      isTvShow: true,
      season: selectedSeasonNumber,
      episode: episode.episodeNumber,
      originalLanguage: details.originalLanguage,
    );
  }
}
