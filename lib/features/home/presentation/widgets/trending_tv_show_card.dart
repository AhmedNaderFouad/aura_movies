import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/genre_map.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/tv_show.dart';

class TrendingTVShowCard extends StatelessWidget {
  final TVShow tvShow;
  final int index;
  final VoidCallback? onTap;

  const TrendingTVShowCard({
    super.key,
    required this.tvShow,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 150.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Poster
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: index == 0
                          ? const Color(0xFFFF5722)
                          : const Color(0xFFF5F5DC),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: tvShow.posterPath != null
                          ? AppCachedNetworkImage(
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                              placeholder: Image.asset(
                                'assets/images/bg_img.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.w900,
                                  color: index == 0
                                      ? Colors.red[900]?.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                // Rating Badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.amber, size: 14.r),
                        SizedBox(width: 4.w),
                        Text(
                          tvShow.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              tvShow.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              getGenreString(tvShow.genreIds),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
