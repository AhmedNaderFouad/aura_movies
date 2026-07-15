import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onWatchNowPressed;
  final VoidCallback? onAddToWatchlistPressed;
  final bool isInWatchlist;
  final bool isComingSoon;
  final bool showWatchNow;
  final bool showAddToWatchlist;

  const ActionButtonsWidget({
    super.key,
    this.onWatchNowPressed,
    this.onAddToWatchlistPressed,
    this.isInWatchlist = false,
    this.isComingSoon = false,
    this.showWatchNow = true,
    this.showAddToWatchlist = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Watch Now Button
          if (showWatchNow)
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: isComingSoon
                    ? null
                    : const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: isComingSoon ? const Color(0xFF404247) : null,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: isComingSoon
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: isComingSoon ? null : onWatchNowPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isComingSoon
                          ? Icons.calendar_today_outlined
                          : Icons.play_arrow_rounded,
                      size: 20.sp,
                      color: isComingSoon ? Colors.white : Colors.black,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isComingSoon ? 'Coming Soon' : 'Watch Now',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isComingSoon ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (showWatchNow && showAddToWatchlist) SizedBox(height: 12.h),
          // Add to Watchlist Button
          if (showAddToWatchlist)
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: onAddToWatchlistPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInWatchlist ? Icons.bookmark : Icons.bookmark_outline,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isInWatchlist ? 'In Watchlist' : 'Add to Watchlist',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
