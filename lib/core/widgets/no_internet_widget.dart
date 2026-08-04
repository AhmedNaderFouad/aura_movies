import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'custom_app_button.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 100.r, color: AppColors.primary),
          SizedBox(height: 24.h),
          Text(
            'No Internet Connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            'Please check your internet connection and try again.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          CustomSignInButton(text: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}
