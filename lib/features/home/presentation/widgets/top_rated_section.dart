import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import 'top_rated_large_card.dart';
import 'top_rated_small_card.dart';

class TopRatedSection extends StatelessWidget {
  final List<dynamic> movies;

  const TopRatedSection({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Top 1 Card
          TopRatedLargeCard(
            movie: movies[0],
            rank: 1,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.movieDetails,
                arguments: movies[0].id,
              );
            },
          ),
          SizedBox(height: 16.h),
          // Top 2 & 3 Cards
          if (movies.length >= 3)
            Row(
              children: [
                Expanded(
                  child: TopRatedSmallCard(
                    movie: movies[1],
                    rank: 2,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.movieDetails,
                        arguments: movies[1].id,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TopRatedSmallCard(
                    movie: movies[2],
                    rank: 3,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.movieDetails,
                        arguments: movies[2].id,
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
