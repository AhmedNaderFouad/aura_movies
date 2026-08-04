import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSlidingToggleWidget extends StatelessWidget {
  final int selectedIndex;
  final List<String> options;
  final ValueChanged<int> onSelectedIndexChanged;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const AppSlidingToggleWidget({
    super.key,
    required this.selectedIndex,
    required this.options,
    required this.onSelectedIndexChanged,
    this.width,
    this.height = 54.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height.h,
      margin: margin,
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24), // Rounded dark background
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double toggleWidth = constraints.maxWidth / options.length;
          return Stack(
            children: [
              // Sliding Active Pill with Neon Glow
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment(
                  (selectedIndex * 2 / (options.length - 1)) - 1,
                  0,
                ),
                child: Container(
                  width: toggleWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00FFAB), // Neon Green
                        Color(0xFF00E699),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFAB).withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Interactive Labels
              Row(
                children: List.generate(options.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onSelectedIndexChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                          child: Text(
                            options[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
