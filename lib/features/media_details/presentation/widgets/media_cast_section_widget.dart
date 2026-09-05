import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/widgets/app_cached_network_image.dart';
import '../../domain/entities/media_credits.dart';

class MediaCastSectionWidget extends StatelessWidget {
  final List<MediaCastMember> cast;

  const MediaCastSectionWidget({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(Icons.group_outlined, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Cast',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Cast List - Horizontal Scroll
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: CastCardWidget(castMember: member),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CastCardWidget extends StatelessWidget {
  final MediaCastMember castMember;

  const CastCardWidget({super.key, required this.castMember});

  String _buildImageUrl(String? profilePath) {
    if (profilePath == null || profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar - 1:1 Square
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _buildImageUrl(castMember.profilePath).isNotEmpty
                      ? AppCachedNetworkImage(
                          imageUrl: _buildImageUrl(castMember.profilePath),
                          errorWidget: _buildFallbackAvatar(),
                        )
                      : _buildFallbackAvatar(),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // Name
            Text(
              castMember.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            // Character Name
            Text(
              castMember.character,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: const Color(0xFF333333),
      child: Center(
        child: Icon(Icons.person, size: 40.sp, color: Colors.white),
      ),
    );
  }
}
