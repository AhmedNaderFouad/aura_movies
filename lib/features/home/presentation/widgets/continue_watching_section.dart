import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../core/services/watch_history_service.dart';
import '../../../../core/models/watch_media_model.dart';
import '../../../../core/utils/watch_now_handler.dart';
import 'home_section_header.dart';

class ContinueWatchingSection extends StatefulWidget {
  const ContinueWatchingSection({super.key});

  @override
  State<ContinueWatchingSection> createState() =>
      _ContinueWatchingSectionState();
}

class _ContinueWatchingSectionState extends State<ContinueWatchingSection> {
  final WatchHistoryService _watchHistoryService = WatchHistoryService();

  @override
  void initState() {
    super.initState();
    // Initial fetch to populate the stream
    _watchHistoryService.getWatchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WatchMediaModel>>(
      stream: _watchHistoryService.historyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSectionHeader(
              title: 'Continue Watching',
              showViewAll: false,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16.w),
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history
                    .map((item) => _buildContinueWatchingCard(context, item))
                    .toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }

  Widget _buildContinueWatchingCard(
    BuildContext context,
    WatchMediaModel item,
  ) {
    return GestureDetector(
      onTap: () {
        WatchNowHandler.handleWatchNow(
          context: context,
          tmdbId: item.id.toString(),
          title: item.title,
          posterPath: item.posterPath,
          isTvShow: item.mediaType == 'tv',
          season: item.seasonNumber,
          episode: item.episodeNumber,
          originalLanguage: item.originalLanguage,
          startPosition: Duration(milliseconds: item.lastPositionMs),
          initialSubtitle: item.subtitleLanguageCode,
        );
      },
      child: Container(
        width: 150.w,
        margin: EdgeInsets.only(right: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: item.posterPath != null
                        ? AppCachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/w300${item.posterPath}',
                            width: 150.w,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: Container(color: Colors.black26),
                          )
                        : Container(
                            width: 150.w,
                            height: double.infinity,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white24,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24.r),
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: item.progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30.r,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.r,
                    right: 8.r,
                    child: GestureDetector(
                      onTap: () {
                        _watchHistoryService.removeFromHistory(
                          item.id,
                          item.mediaType,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.mediaType == 'tv' &&
                item.seasonNumber != null &&
                item.episodeNumber != null) ...[
              SizedBox(height: 2.h),
              Text(
                'S${item.seasonNumber} E${item.episodeNumber}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
