import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get title => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get subtitle => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get input =>
      TextStyle(color: AppColors.textPrimary, fontSize: 16.sp);

  static TextStyle get button => TextStyle(
    color: AppColors.buttonText,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get appBarTitle => TextStyle(
    color: AppColors.primary,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );
}
