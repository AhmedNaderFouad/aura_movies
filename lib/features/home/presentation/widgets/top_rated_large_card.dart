import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';

class TopRatedLargeCard extends StatelessWidget {
  final dynamic movie;
  final int rank;
  final VoidCallback? onTap;

  const TopRatedLargeCard({
    super.key,
    required this.movie,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            // Rank background number
            Positioned(
              right: 20.w,
              bottom: -20.h,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 150.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: 100.w,
                      height: double.infinity,
                      child: movie.posterPath != null
                          ? AppCachedNetworkImage(
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              placeholder: Image.asset(
                                'assets/images/bg_img.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'TOP',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'RATED $rank',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            movie.title ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${movie.voteAverage}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '240k Ratings',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
