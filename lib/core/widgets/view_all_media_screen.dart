import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../routing/routes.dart';
import '../../features/home/domain/entities/movie.dart';
import '../../features/home/domain/entities/tv_show.dart';
import '../../features/home/presentation/widgets/trending_movie_card.dart';
import '../../features/home/presentation/widgets/trending_tv_show_card.dart';

class ViewAllMediaScreen extends StatelessWidget {
  final String sectionTitle;
  final List<dynamic> mediaList;

  const ViewAllMediaScreen({
    super.key,
    required this.sectionTitle,
    required this.mediaList,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Dynamic DateTime Sorting (Newest to Oldest)
    final sortedList = List.from(mediaList);
    sortedList.sort((a, b) {
      DateTime? dateA;
      DateTime? dateB;

      if (a is Movie) {
        dateA = a.releaseDate != null ? DateTime.tryParse(a.releaseDate!) : null;
      } else if (a is TVShow) {
        dateA = a.firstAirDate != null ? DateTime.tryParse(a.firstAirDate!) : null;
      }

      if (b is Movie) {
        dateB = b.releaseDate != null ? DateTime.tryParse(b.releaseDate!) : null;
      } else if (b is TVShow) {
        dateB = b.firstAirDate != null ? DateTime.tryParse(b.firstAirDate!) : null;
      }

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // Nulls at the end
      if (dateB == null) return -1;

      return dateB.compareTo(dateA); // Newest to Oldest
    });

    // 2. Enforce 30-item maximum ceiling
    final displayList = sortedList.take(30).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          sectionTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.48, // Balanced for 3-item row with titles
                ),
                itemBuilder: (context, index) {
                  final item = displayList[index];
                  // We pass a constant index or similar to avoid distracting background colors 
                  // if desired, but here we'll use actual index for grid positioning.
                  if (item is Movie) {
                    return TrendingMovieCard(
                      movie: item,
                      index: index + 10, // Offset to avoid special first-item color if unwanted
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.movieDetails,
                        arguments: item.id,
                      ),
                    );
                  } else {
                    return TrendingTVShowCard(
                      tvShow: item as TVShow,
                      index: index + 10, // Offset to avoid special first-item color
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.tvShowDetails,
                        arguments: item.id,
                      ),
                    );
                  }
                },
              ),
            ),
            
            // Custom Footer
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                children: [
                  Text(
                    'See more ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, Routes.search),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Text(
                        'Search More Content',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
