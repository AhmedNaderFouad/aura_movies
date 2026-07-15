import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_carousel_slider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/trending_movie_card.dart';
import '../widgets/trending_tv_show_card.dart';
import '../widgets/upcoming_movie_card.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/tv_show.dart';
import '../../../watchlist/presentation/cubit/watchlist_cubit.dart';
import '../../../watchlist/presentation/cubit/watchlist_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<WatchlistCubit>().loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          appBar: const HomeAppBar(),
          body: _buildBody(state),
          bottomNavigationBar: state is HomeNoInternet
              ? null
              : CustomBottomNavBar(
                  currentIndex: _currentNavIndex,
                  onTap: (index) {
                    setState(() => _currentNavIndex = index);
                    // Navigate to browse screen when Browse button is tapped
                    if (index == 1) {
                      Navigator.pushNamed(context, Routes.browse);
                      // Reset to home index after navigation
                      setState(() => _currentNavIndex = 0);
                    } else if (index == 2) {
                      Navigator.pushNamed(context, Routes.watchlist);
                      setState(() => _currentNavIndex = 0);
                    } else if (index == 3) {
                      Navigator.pushNamed(context, Routes.profile);
                      setState(() => _currentNavIndex = 0);
                    }
                  },
                ),
        );
      },
    );
  }

  Widget _buildBody(HomeState state) {
    if (state is HomeLoading) {
      return _buildLoadingState();
    }
    if (state is HomeSuccess) {
      return _buildContent(state);
    }
    if (state is HomeError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    if (state is HomeNoInternet) {
      return Center(
        child: NoInternetWidget(
          onRetry: () => context.read<HomeCubit>().loadHomeData(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(HomeSuccess state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Carousel Slider Section
          BlocListener<WatchlistCubit, WatchlistState>(
            listener: (context, state) {
              if (state is WatchlistToggleSuccess) {
                CustomSnackBar.show(context, message: state.message);
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
          _buildSectionHeader(
            'Trending TV Shows',
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
                  child: TrendingTVShowCard(
                    tvShow: state.trendingTvShows[index],
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

          // 3. Trending Now Section
          _buildSectionHeader(
            'Trending Movies',
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
                  child: TrendingMovieCard(
                    movie: state.trendingMovies[index],
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
          _buildSectionHeader('Top Rated This Week'),
          _buildTopRatedSection(state.topRatedMovies),

          SizedBox(height: 32.h),

          // 5. Upcoming TV Shows Section
          _buildSectionHeader('Upcoming TV Shows'),
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
                        child: TrendingTVShowCard(
                          tvShow: state.upcomingTvShows[index],
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
          _buildSectionHeader('Upcoming Movies'),
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

  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopRatedSection(List<dynamic> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Top 1 Card
          _buildTopRatedLargeCard(movies[0], 1),
          SizedBox(height: 16.h),
          // Top 2 & 3 Cards
          if (movies.length >= 3)
            Row(
              children: [
                Expanded(child: _buildTopRatedSmallCard(movies[1], 2)),
                SizedBox(width: 16.w),
                Expanded(child: _buildTopRatedSmallCard(movies[2], 3)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTopRatedLargeCard(dynamic movie, int rank) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.movieDetails, arguments: movie.id);
      },
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            // Rank background number
            Positioned(
              right: 20.w,
              bottom: -20.h,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 150.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: 100.w,
                      height: double.infinity,
                      child: movie.posterPath != null
                          ? AppCachedNetworkImage(
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              placeholder: Image.asset(
                                'assets/images/bg_img.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TOP',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RATED $rank',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          movie.title ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${movie.voteAverage}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '240k Ratings',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedSmallCard(dynamic movie, int rank) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.movieDetails, arguments: movie.id);
      },
      child: Container(
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: movie.backdropPath != null
                  ? AppCachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                      placeholder: Image.asset(
                        'assets/images/bg_img.jpg',
                        fit: BoxFit.cover,
                      ),
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(color: Colors.black),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    movie.title ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        '${movie.voteAverage}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Text(
                'TOP RATED $rank',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
