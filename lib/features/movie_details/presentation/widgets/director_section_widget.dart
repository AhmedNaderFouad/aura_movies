import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/movie_credits.dart';

class DirectorSectionWidget extends StatelessWidget {
  final CrewMemberEntity? director;

  const DirectorSectionWidget({
    super.key,
    this.director,
  });

  String _buildImageUrl(String? profilePath) {
    if (profilePath == null || profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  Widget build(BuildContext context) {
    if (director == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
                child: _buildImageUrl(director!.profilePath).isNotEmpty
                    ? AppCachedNetworkImage(
                        imageUrl: _buildImageUrl(director!.profilePath),
                        errorWidget: _buildFallbackAvatar(),
                      )
                    : _buildFallbackAvatar(),
            ),
          ),
          SizedBox(width: 16.w),
          // Info
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
                director!.name,
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
        child: Icon(
          Icons.person,
          size: 24.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
