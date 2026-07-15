import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/movie_player_screen_widget.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/tv_show.dart';

class HomeCarouselSlider extends StatefulWidget {
  final List<Movie> trendingMovies;
  final List<TVShow> trendingTvShows;
  final Function(dynamic) onWatchlistPressed;
  final bool Function(int, bool) isInWatchlist;

  const HomeCarouselSlider({
    super.key,
    required this.trendingMovies,
    required this.trendingTvShows,
    required this.onWatchlistPressed,
    required this.isInWatchlist,
  });

  @override
  State<HomeCarouselSlider> createState() => _HomeCarouselSliderState();
}

class _HomeCarouselSliderState extends State<HomeCarouselSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    // Combine Top 2 Movies and Top 2 TV Shows
    final List<dynamic> items = [];
    if (widget.trendingMovies.length >= 2) {
      items.addAll(widget.trendingMovies.take(2));
    } else {
      items.addAll(widget.trendingMovies);
    }

    if (widget.trendingTvShows.length >= 2) {
      items.addAll(widget.trendingTvShows.take(2));
    } else {
      items.addAll(widget.trendingTvShows);
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          items: items.map((item) {
            final bool isMovie = item is Movie;
            final String title = isMovie ? item.title : item.name;
            final String? backdropPath = item.backdropPath;
            final int id = item.id;

            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      isMovie ? Routes.movieDetails : Routes.tvShowDetails,
                      arguments: id,
                    );
                  },
                  child: Stack(
                    children: [
                      // Backdrop Image
                      Positioned.fill(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: backdropPath != null
                                ? AppCachedNetworkImage(
                                    imageUrl:
                                        'https://image.tmdb.org/t/p/original$backdropPath',
                                    placeholder: Image.asset(
                                      'assets/images/bg_img.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(color: AppColors.surface),
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Action Controls & Title
                      Positioned(
                        bottom: 20.h,
                        left: 20.w,
                        right: 20.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Watchlist Button
                                _buildCircularButton(
                                  icon: widget.isInWatchlist(id, isMovie) 
                                      ? Icons.check 
                                      : Icons.add,
                                  onPressed: () => widget.onWatchlistPressed(item),
                                ),
                                SizedBox(width: 30.w),
                                // Play Button
                                _buildPlayButton(context, item, isMovie),
                                SizedBox(width: 30.w),
                                // Info Button
                                _buildCircularButton(
                                  icon: Icons.info_outline,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      isMovie ? Routes.movieDetails : Routes.tvShowDetails,
                                      arguments: id,
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // Title
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: 450.h,
            viewportFraction: 0.85,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            enlargeFactor: 0.3,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          carouselController: _controller,
        ),
        SizedBox(height: 12.h),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24.r),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, dynamic item, bool isMovie) {
    return Container(
      width: 60.r,
      height: 60.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.play_arrow_rounded, color: Colors.black, size: 36.r),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoviePlayerScreen(
                id: item.id.toString(),
                title: isMovie ? item.title : item.name,
                isTvShow: !isMovie,
                seasonNumber: isMovie ? null : 1,
                episodeNumber: isMovie ? null : 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
