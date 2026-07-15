import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class AppSizes {
  // Spacing
  static double get s4 => 4.r;
  static double get s8 => 8.r;
  static double get s12 => 12.r;
  static double get s16 => 16.r;
  static double get s20 => 20.r;
  static double get s24 => 24.r;
  static double get s32 => 32.r;
  static double get s40 => 40.r;
  static double get s48 => 48.r;
  static double get s64 => 64.r;

  // Icons
  static double get iconSmall => 18.r;
  static double get iconMedium => 24.r;
  static double get iconLarge => 32.r;
  static double get iconExtraLarge => 48.r;

  // Radius
  static double get radiusSmall => 8.r;
  static double get radiusMedium => 12.r;
  static double get radiusLarge => 20.r;
  static double get radiusExtraLarge => 30.r;

  // Paddings
  static EdgeInsets get paddingAll16 => EdgeInsets.all(s16);
  static EdgeInsets get paddingAll24 => EdgeInsets.all(s24);
  static EdgeInsets get paddingH24 => EdgeInsets.symmetric(horizontal: s24);
}
