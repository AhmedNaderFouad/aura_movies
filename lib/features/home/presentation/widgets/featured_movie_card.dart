import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/movie.dart';

class FeaturedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onWatchlistPressed;
  final VoidCallback? onTap;
  final bool isInWatchlist;

  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.onWatchlistPressed,
    this.onTap,
    this.isInWatchlist = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 400.h,
        width: double.infinity,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: movie.backdropPath != null
                  ? AppCachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/original${movie.backdropPath}',
                      placeholder: Image.asset(
                        'assets/images/bg_img.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(color: AppColors.surface),
            ),
            // Bottom gradient for readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Watchlist Button (Glassmorphism) - Moved to bottom
            Positioned(
              bottom: 30.h,
              left: 20.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: InkWell(
                    onTap: onWatchlistPressed,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isInWatchlist ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 24.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isInWatchlist ? 'In Watchlist' : 'Watchlist',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





