import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../features/home/domain/entities/movie.dart';
import '../../../../features/home/domain/entities/tv_show.dart';

class SearchResultCard extends StatelessWidget {
  final dynamic item;
  final bool showMediaType;

  const SearchResultCard({
    super.key,
    required this.item,
    this.showMediaType = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMovie = item is Movie;
    final String title = isMovie ? item.title : (item as TVShow).name;
    final String? posterPath = isMovie
        ? item.posterPath
        : (item as TVShow).posterPath;

    String date = 'N/A';
    if (isMovie) {
      date = item.releaseDate ?? 'N/A';
    } else {
      final tv = item as TVShow;
      date = tv.firstAirDate ?? 'TV Series';
    }

    final double voteAverage = isMovie
        ? item.voteAverage ?? 0.0
        : (item as TVShow).voteAverage ?? 0.0;

    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        await SystemChannels.textInput.invokeMethod('TextInput.hide');
        await Future.delayed(const Duration(milliseconds: 100));

        if (!context.mounted) return;

        if (isMovie) {
          Navigator.pushNamed(context, Routes.movieDetails, arguments: item.id);
        } else {
          Navigator.pushNamed(
            context,
            Routes.tvShowDetails,
            arguments: item.id,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Poster Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: SizedBox(
                width: 90.w,
                height: 140.h,
                child: posterPath != null
                    ? AppCachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
                        placeholder: Image.asset(
                          'assets/images/bg_img.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        color: AppColors.background,
                        child: Icon(
                          isMovie ? Icons.movie_rounded : Icons.tv_rounded,
                          color: AppColors.textSecondary,
                          size: 32.r,
                        ),
                      ),
              ),
            ),
            // Result Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          isMovie ? 'Released: $date' : 'First Aired: $date',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              voteAverage.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        if (showMediaType) ...[
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isMovie
                                  ? Colors.blue.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              isMovie ? 'Movie' : 'TV Series',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isMovie ? Colors.blue : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Arrow Icon
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 20.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
