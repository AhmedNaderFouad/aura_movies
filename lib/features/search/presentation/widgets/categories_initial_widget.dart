import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class CategoriesInitialWidget extends StatelessWidget {
  const CategoriesInitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tune_rounded,
            size: 80.r,
            color: AppColors.primary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Customize your filters and tap Search to explore',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
