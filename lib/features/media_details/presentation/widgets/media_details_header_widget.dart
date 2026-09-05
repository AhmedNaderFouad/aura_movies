import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/widgets/app_cached_network_image.dart';
import '../../domain/entities/media_details.dart';

class MediaDetailsHeaderWidget extends StatelessWidget {
  final MediaDetails mediaDetails;

  const MediaDetailsHeaderWidget({super.key, required this.mediaDetails});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop Image
        SizedBox(
          width: double.infinity,
          height: 280.h,
          child: mediaDetails.backdropPath != null
              ? AppCachedNetworkImage(
                  imageUrl:
                      'https://image.tmdb.org/t/p/w780${mediaDetails.backdropPath}',
                  placeholder: Container(color: AppColors.surface),
                  errorWidget: Container(color: AppColors.surface),
                )
              : Container(color: AppColors.surface),
        ),
        // Gradient Overlay
        Container(
          width: double.infinity,
          height: 280.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
