import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/shimmer_loading_widget.dart';

class DiscoverMediaShimmer extends StatelessWidget {
  const DiscoverMediaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.5,
      ),
      itemCount: 9, // Show a few shimmer cards
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ShimmerLoadingWidget(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 24.r,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: ShimmerLoadingWidget(
                    width: 40.w,
                    height: 22.h,
                    borderRadius: 10.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ShimmerLoadingWidget(width: 100.w, height: 16.h, borderRadius: 4.r),
            SizedBox(height: 4.h),
            ShimmerLoadingWidget(width: 60.w, height: 12.h, borderRadius: 4.r),
          ],
        );
      },
    );
  }
}
