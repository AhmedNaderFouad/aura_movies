import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_cached_network_image.dart';

class TopRatedSmallCard extends StatelessWidget {
  final dynamic movie;
  final int rank;
  final VoidCallback? onTap;

  const TopRatedSmallCard({
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
        height: 150.h,
        decoration: BoxDecoration(
          color: Colors.black, // Fallback color
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: movie.backdropPath != null
                  ? AppCachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                      placeholder: Image.asset(
                        'assets/images/bg_img.jpg',
                        fit: BoxFit.cover,
                      ),
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(color: Colors.black),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    movie.title ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        '${movie.voteAverage}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Text(
                'TOP RATED $rank',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
