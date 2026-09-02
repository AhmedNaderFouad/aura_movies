import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/tv_show.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_carousel_slider.dart';
import '../widgets/trending_card.dart';
import '../widgets/upcoming_movie_card.dart';
import '../widgets/home_section_header.dart';
import '../widgets/top_rated_section.dart';
import '../../../watchlist/presentation/cubit/watchlist_cubit.dart';
import '../../../watchlist/presentation/cubit/watchlist_state.dart';

class HomeContent extends StatelessWidget {
  final HomeSuccess state;

  const HomeContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Carousel Slider Section
          BlocListener<WatchlistCubit, WatchlistState>(
            listener: (context, watchlistState) {
              if (watchlistState is WatchlistToggleSuccess) {
                CustomSnackBar.show(context, message: watchlistState.message);
              }
            },
            child: BlocBuilder<WatchlistCubit, WatchlistState>(
              builder: (context, watchlistState) {
                return HomeCarouselSlider(
                  trendingMovies: state.trendingMovies,
                  trendingTvShows: state.trendingTvShows,
                  onWatchlistPressed: (item) {
                    if (item is TVShow) {
                      final movie = Movie(
                        id: item.id,
                        title: item.name,
                        backdropPath: item.backdropPath,
                        posterPath: item.posterPath,
                        overview: item.overview,
                        voteAverage: item.voteAverage,
                        releaseDate: item.firstAirDate,
                        genreIds: item.genreIds,
                        isTvShow: true,
                      );
                      context.read<WatchlistCubit>().toggleWatchlist(movie);
                    } else if (item is Movie) {
                      context.read<WatchlistCubit>().toggleWatchlist(item);
                    }
                  },
                  isInWatchlist: (id, isMovie) {
                    if (watchlistState is WatchlistLoaded) {
                      return watchlistState.movies.any((m) => m.id == id);
                    }
                    return false;
                  },
                );
              },
            ),
          ),

          SizedBox(height: 24.h),

          // 2. Trending TV Shows Section
          HomeSectionHeader(
            title: 'Trending TV Shows',
            showViewAll: true,
            onViewAll: () => Navigator.pushNamed(
              context,
              Routes.viewAllMedia,
              arguments: {
                'title': 'Trending TV Shows',
                'list': state.trendingTvShows,
              },
            ),
          ),
          SizedBox(
            height: 320.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16.w),
              itemCount: state.trendingTvShows.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: TrendingCard(
                    posterPath: state.trendingTvShows[index].posterPath,
                    voteAverage: state.trendingTvShows[index].voteAverage,
                    title: state.trendingTvShows[index].name,
                    genreIds: state.trendingTvShows[index].genreIds,
                    index: index,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.tvShowDetails,
                        arguments: state.trendingTvShows[index].id,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 24.h),

          // 3. Trending Movies Section
          HomeSectionHeader(
            title: 'Trending Movies',
            showViewAll: true,
            onViewAll: () => Navigator.pushNamed(
              context,
              Routes.viewAllMedia,
              arguments: {
                'title': 'Trending Movies',
                'list': state.trendingMovies,
              },
            ),
          ),
          SizedBox(
            height: 320.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16.w),
              itemCount: state.trendingMovies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: TrendingCard(
                    posterPath: state.trendingMovies[index].posterPath,
                    voteAverage: state.trendingMovies[index].voteAverage,
                    title: state.trendingMovies[index].title,
                    genreIds: state.trendingMovies[index].genreIds,
                    index: index,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.movieDetails,
                        arguments: state.trendingMovies[index].id,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 32.h),

          // 4. Top Rated This Week Section
          const HomeSectionHeader(title: 'Top Rated'),
          TopRatedSection(movies: state.topRatedMovies),

          SizedBox(height: 32.h),

          // 5. Upcoming TV Shows Section
          const HomeSectionHeader(title: 'Upcoming TV Shows'),
          SizedBox(
            height: 320.h,
            child: state.upcomingTvShows.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming TV shows',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 16.w),
                    itemCount: state.upcomingTvShows.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 20.w),
                        child: TrendingCard(
                          posterPath: state.upcomingTvShows[index].posterPath,
                          voteAverage: state.upcomingTvShows[index].voteAverage,
                          title: state.upcomingTvShows[index].name,
                          genreIds: state.upcomingTvShows[index].genreIds,
                          index: index,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.tvShowDetails,
                              arguments: state.upcomingTvShows[index].id,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),

          SizedBox(height: 24.h),

          // 6. Upcoming Movies Section
          const HomeSectionHeader(title: 'Upcoming Movies'),
          SizedBox(
            height: 265.h,
            child: state.upcomingMovies.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming movies',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 16.w),
                    itemCount: state.upcomingMovies.length,
                    itemBuilder: (context, index) {
                      return UpcomingMovieCard(
                        movie: state.upcomingMovies[index],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.movieDetails,
                            arguments: state.upcomingMovies[index].id,
                          );
                        },
                      );
                    },
                  ),
          ),

          SizedBox(height: 130.h),
        ],
      ),
    );
  }
}
