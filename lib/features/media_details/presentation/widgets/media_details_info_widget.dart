import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/widgets/app_cached_network_image.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_credits.dart';

class MediaDetailsInfoWidget extends StatelessWidget {
  final MediaDetails mediaDetails;
  final MediaCrewMember? director;

  const MediaDetailsInfoWidget({
    super.key,
    required this.mediaDetails,
    this.director,
  });

  String _formatCurrency(int? value) {
    if (value == null || value == 0) return 'N/A';
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String valueStr = value.toString();
    return '\$${valueStr.replaceAllMapped(formatter, (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Details Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              _DetailRow(
                label: 'Original Language',
                value: mediaDetails.originalLanguage.toUpperCase(),
              ),
              if (!mediaDetails.isTvShow) ...[
                SizedBox(height: 16.h),
                _DetailRow(
                  label: 'Budget',
                  value: _formatCurrency(mediaDetails.budget),
                ),
                SizedBox(height: 16.h),
                _DetailRow(
                  label: 'Revenue',
                  value: _formatCurrency(mediaDetails.revenue),
                ),
              ],
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      mediaDetails.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Genres Card
        if (mediaDetails.genres.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GENRES',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: mediaDetails.genres.map((genre) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        genre.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        if (director != null) ...[
          SizedBox(height: 16.h),
          _DirectorSection(director: director!),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _DirectorSection extends StatelessWidget {
  final MediaCrewMember director;

  const _DirectorSection({required this.director});

  String _buildImageUrl(String? profilePath) {
    if (profilePath == null || profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: _buildImageUrl(director.profilePath).isNotEmpty
                  ? AppCachedNetworkImage(
                      imageUrl: _buildImageUrl(director.profilePath),
                      errorWidget: _buildFallbackAvatar(),
                    )
                  : _buildFallbackAvatar(),
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DIRECTED BY',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                director.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: const Color(0xFF333333),
      child: Center(
        child: Icon(Icons.person, size: 24.sp, color: Colors.white),
      ),
    );
  }
}
