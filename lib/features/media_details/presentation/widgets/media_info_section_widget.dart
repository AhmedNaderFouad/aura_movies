import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import '../../domain/entities/media_details.dart';

class MediaInfoSectionWidget extends StatelessWidget {
  final MediaDetails mediaDetails;

  const MediaInfoSectionWidget({super.key, required this.mediaDetails});

  String _formatDate(String? releaseDate) {
    if (releaseDate == null || releaseDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(releaseDate);
      return '${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return releaseDate;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    if (mediaDetails.isTvShow) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mediaDetails.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20.r),
                SizedBox(width: 4.w),
                Text(
                  mediaDetails.voteAverage.toStringAsFixed(1),
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
      );
    }

    // Movie Info Section Logic (Exact Restore from your old code)
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Row
          Row(
            children: [
              // Featured Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'FEATURED CONTENT',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Rating Badge
              Row(
                children: [
                  Icon(Icons.star, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text(
                    mediaDetails.voteAverage.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Title
          Text(
            mediaDetails.title.toUpperCase(),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.1,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          // Runtime and Release Date
          Row(
            children: [
              if (mediaDetails.runtime != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${mediaDetails.runtime! ~/ 60}h ${mediaDetails.runtime! % 60}m',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                ),
              Icon(
                Icons.calendar_today_outlined,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                _formatDate(mediaDetails.releaseDate),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Genres text
          if (mediaDetails.genres.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  mediaDetails.genres.map((g) => g.name).join(' / '),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
