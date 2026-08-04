import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import '../../domain/entities/movie_details.dart';

class MovieInfoSectionWidget extends StatelessWidget {
  final MovieDetails movieDetails;

  const MovieInfoSectionWidget({super.key, required this.movieDetails});

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
                    movieDetails.voteAverage.toStringAsFixed(1),
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
            movieDetails.title.toUpperCase(),
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
              if (movieDetails.runtime != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${movieDetails.runtime! ~/ 60}h ${movieDetails.runtime! % 60}m',
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
                _formatDate(movieDetails.releaseDate),
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
          if (movieDetails.genres.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  movieDetails.genres.map((g) => g.name).join(' / '),
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
