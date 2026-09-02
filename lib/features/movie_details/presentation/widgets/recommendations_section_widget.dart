import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/routing/routes.dart';
import '../../../home/domain/entities/movie.dart';
import '../../../home/presentation/widgets/trending_card.dart';

class RecommendationsSectionWidget extends StatelessWidget {
  final List<Movie> recommendations;

  const RecommendationsSectionWidget({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(
                Icons.movie_filter_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Related Movies',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Recommendations List
        SizedBox(
          height: 295.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final movie = recommendations[index];
              return Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: TrendingCard(
                  posterPath: movie.posterPath,
                  voteAverage: movie.voteAverage,
                  title: movie.title,
                  genreIds: movie.genreIds,
                  index:
                      index +
                      1, // Offset to avoid orange background on first item if desired
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.movieDetails,
                      arguments: movie.id,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
