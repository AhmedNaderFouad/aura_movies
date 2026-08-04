import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/movie.dart';

class UpcomingMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const UpcomingMovieCard({super.key, required this.movie, this.onTap});

  String _formatReleaseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Coming Soon';
    try {
      final date = DateTime.parse(dateStr);
      return 'Coming ${DateFormat('MMMM d').format(date)}';
    } catch (_) {
      return 'Coming Soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: SizedBox(
                height: 150.h,
                width: double.infinity,
                child: movie.backdropPath != null
                    ? AppCachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                        placeholder: Image.asset(
                          'assets/images/bg_img.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(color: Colors.grey[900]),
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatReleaseDate(movie.releaseDate),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 20.r,
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
