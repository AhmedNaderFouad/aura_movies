import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/genre_map.dart';
import '../../../../core/widgets/app_cached_network_image.dart';

class TrendingCard extends StatelessWidget {
  final String? posterPath;
  final double? voteAverage;
  final String title;
  final List<int> genreIds;
  final int index;
  final VoidCallback? onTap;

  const TrendingCard({
    super.key,
    required this.posterPath,
    required this.voteAverage,
    required this.title,
    required this.genreIds,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150.w,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
                        color: AppColors.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: posterPath != null
                            ? AppCachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w500$posterPath',
                                placeholder: Image.asset(
                                  'assets/images/bg_img.jpg',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.movie_rounded,
                                  color: Colors.white24,
                                  size: 40,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            voteAverage?.toStringAsFixed(1) ?? 'N/A',
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
                title,
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
                getGenreString(genreIds),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
