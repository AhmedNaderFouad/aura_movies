import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/movie_credits.dart';

class CastSectionWidget extends StatelessWidget {
  final List<CastMemberEntity> cast;

  const CastSectionWidget({
    super.key,
    required this.cast,
  });

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
              Icon(
                Icons.group_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Top Cast',
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
        // Cast List - 2x2 Grid
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.w,
            ),
            itemCount: cast.length > 4 ? 4 : cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return CastCardWidget(castMember: member);
            },
          ),
        ),
      ],
    );
  }
}

class CastCardWidget extends StatelessWidget {
  final CastMemberEntity castMember;

  const CastCardWidget({
    super.key,
    required this.castMember,
  });

  String _buildImageUrl(String? profilePath) {
    if (profilePath == null || profilePath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Expanded(
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
              fontSize: 13.sp,
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
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
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
          size: 40.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
