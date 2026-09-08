import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../core/models/media.dart';

class UpcomingMediaCard extends StatelessWidget {
  final Media media;
  final VoidCallback? onTap;

  const UpcomingMediaCard({super.key, required this.media, this.onTap});

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: SizedBox(
                  height: 150.h,
                  width: double.infinity,
                  child: media.backdropPath != null
                      ? AppCachedNetworkImage(
                          imageUrl:
                              'https://image.tmdb.org/t/p/w500${media.backdropPath}',
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
                            media.title,
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
                            _formatReleaseDate(media.releaseDate),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: media.isTvShow
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              media.isTvShow ? 'TV Series' : 'Movie',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: media.isTvShow
                                    ? Colors.orange
                                    : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
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
      ),
    );
  }
}
