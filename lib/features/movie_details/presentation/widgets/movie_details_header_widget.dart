import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/movie_details.dart';

class MovieDetailsHeaderWidget extends StatelessWidget {
  final MovieDetails movieDetails;

  const MovieDetailsHeaderWidget({super.key, required this.movieDetails});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop Image
        SizedBox(
          width: double.infinity,
          height: 280.h,
          child: movieDetails.backdropPath != null
              ? AppCachedNetworkImage(
                  imageUrl:
                      'https://image.tmdb.org/t/p/w500${movieDetails.backdropPath}',
                  errorWidget: Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
        ),
        // Dark overlay gradient
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
