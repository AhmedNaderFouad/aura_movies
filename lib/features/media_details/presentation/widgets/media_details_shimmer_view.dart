import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/constants/media_type.dart';
import 'package:aura_movies/core/widgets/shimmer_loading_widget.dart';

class MediaDetailsShimmerView extends StatelessWidget {
  final MediaType mediaType;

  const MediaDetailsShimmerView({super.key, required this.mediaType});

  @override
  Widget build(BuildContext context) {
    if (mediaType == MediaType.tv) {
      return _buildTvLoadingWidget();
    }
    return _buildMovieLoadingWidget();
  }

  Widget _buildMovieLoadingWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoadingWidget(
            width: double.infinity,
            height: 280.h,
            borderRadius: 0,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerLoadingWidget(
                      width: 120.w,
                      height: 24.h,
                      borderRadius: 4.r,
                    ),
                    SizedBox(width: 8.w),
                    ShimmerLoadingWidget(
                      width: 40.w,
                      height: 24.h,
                      borderRadius: 4.r,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ShimmerLoadingWidget(
                  width: 280.w,
                  height: 32.h,
                  borderRadius: 4.r,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    ShimmerLoadingWidget(
                      width: 80.w,
                      height: 16.h,
                      borderRadius: 4.r,
                    ),
                    SizedBox(width: 16.w),
                    ShimmerLoadingWidget(
                      width: 80.w,
                      height: 16.h,
                      borderRadius: 4.r,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ShimmerLoadingWidget(
                  width: 200.w,
                  height: 16.h,
                  borderRadius: 4.r,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 56.h,
                  borderRadius: 30.r,
                ),
                SizedBox(height: 12.h),
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 56.h,
                  borderRadius: 30.r,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              children: [
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 150.h,
                  borderRadius: 24.r,
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 150.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildTvLoadingWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoadingWidget(
            width: double.infinity,
            height: 280.h,
            borderRadius: 0,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingWidget(
                  width: 250.w,
                  height: 32.h,
                  borderRadius: 4.0,
                ),
                SizedBox(height: 16.h),
                ShimmerLoadingWidget(
                  width: 100.w,
                  height: 20.h,
                  borderRadius: 4.0,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              children: [
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 150.h,
                  borderRadius: 24.r,
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 150.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ShimmerLoadingWidget(
              width: double.infinity,
              height: 56.h,
              borderRadius: 30.0,
            ),
          ),
          SizedBox(height: 32.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 45.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: ShimmerLoadingWidget(
                      width: 100.w,
                      height: 45.h,
                      borderRadius: 20.r,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: List.generate(
                    4,
                    (index) => _buildShimmerEpisodeItem(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEpisodeItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Stack(
        children: [
          ShimmerLoadingWidget(
            width: double.infinity,
            height: 110.h,
            borderRadius: 16.r,
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130.w,
                  height: 85.h,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 100.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
