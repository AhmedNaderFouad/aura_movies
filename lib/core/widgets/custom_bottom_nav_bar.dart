import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  final int index;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      BottomNavItem(icon: Icons.home_filled, label: 'HOME', index: 0),
      BottomNavItem(icon: Icons.search_rounded, label: 'SEARCH', index: 1),
      BottomNavItem(icon: Icons.bookmark_rounded, label: 'WATCHLIST', index: 2),
      BottomNavItem(icon: Icons.person_rounded, label: 'PROFILE', index: 3),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F14).withOpacity(0.95),
        borderRadius: BorderRadius.circular(35.r),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _buildNavItem(
              item: items[index],
              isActive: currentIndex == index,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 26.r,
          ),
          SizedBox(height: 6.h),
          Text(
            item.label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
