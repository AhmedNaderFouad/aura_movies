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
import '../widgets/continue_watching_section.dart';
import '../widgets/trending_card.dart';
import '../widgets/upcoming_media_card.dart';
import '../widgets/home_section_header.dart';
import '../widgets/top_rated_section.dart';
import '../widgets/brand_section.dart';
import '../../domain/entities/brand_entity.dart';
import '../../../watchlist/presentation/cubit/watchlist_cubit.dart';
import '../../../watchlist/presentation/cubit/watchlist_state.dart';

class HomeContent extends StatelessWidget {
  final HomeSuccess state;

  const HomeContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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

          // 2. Continue Watching Section
          const ContinueWatchingSection(),

          // 3. Trending TV Shows Section
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

          // 5. Popular Networks Section (Streaming Platforms)
          BrandSection(
            title: 'Popular Networks',
            brands: const [
              BrandEntity(
                id: 8,
                name: 'Netflix',
                logoPath: 'assets/logos/netflix.png',
                networkId: 213,
                isNetwork: true,
              ),
              BrandEntity(
                id: 9,
                name: 'Amazon Prime Video',
                logoPath: 'assets/logos/amazon-prime-video.png',
                networkId: 1024,
                isNetwork: true,
              ),
              BrandEntity(
                id: 337,
                name: 'Disney+',
                logoPath: 'assets/logos/disney.png',
                networkId: 2739,
                isNetwork: true,
              ),
              BrandEntity(
                id: 350,
                name: 'Apple TV+',
                logoPath: 'assets/logos/apple-tv.png',
                networkId: 2552,
                isNetwork: true,
              ),
              BrandEntity(
                id: 1899,
                name: 'HBO',
                logoPath: 'assets/logos/hbo.png',
                networkId: 49,
                isNetwork: true,
              ),
              BrandEntity(
                id: 15,
                name: 'Hulu',
                logoPath: 'assets/logos/hulu.png',
                networkId: 453,
                isNetwork: true,
              ),
              BrandEntity(
                id: 80,
                name: 'AMC',
                logoPath: 'assets/logos/amc.png',
                networkId: 67,
                isNetwork: true,
              ),
            ],
            onBrandTap: (brand) {
              Navigator.pushNamed(
                context,
                Routes.discoverMedia,
                arguments: brand,
              );
            },
          ),

          SizedBox(height: 32.h),

          // 6. Popular Companies Section
          BrandSection(
            title: 'Popular Companies',
            brands: const [
              BrandEntity(
                id: 420,
                name: 'Marvel Studios',
                logoPath: 'assets/logos/marvel-studios.png',
                companyId: 420,
              ),
              BrandEntity(
                id: 3,
                name: 'Pixar Animation Studios',
                logoPath: 'assets/logos/pixar.png',
                companyId: 3,
              ),
              BrandEntity(
                id: 2,
                name: 'Walt Disney Pictures',
                logoPath: 'assets/logos/walt-disney-pictures.png',
                companyId: 2,
              ),
              BrandEntity(
                id: 174,
                name: 'Warner Bros.',
                logoPath: 'assets/logos/wb-warner-bros.png',
                companyId: 174,
              ),
              BrandEntity(
                id: 4,
                name: 'Paramount Pictures',
                logoPath: 'assets/logos/paramount-pictures.png',
                companyId: 4,
              ),
              BrandEntity(
                id: 25,
                name: '20th Century Fox',
                logoPath: 'assets/logos/20th-century-fox.png',
                companyId: 25,
              ),
            ],
            onBrandTap: (brand) {
              Navigator.pushNamed(
                context,
                Routes.discoverMedia,
                arguments: brand,
              );
            },
          ),

          SizedBox(height: 32.h),

          // 7. Upcoming Releases Section
          const HomeSectionHeader(title: 'Upcoming Releases'),
          SizedBox(
            height: 265.h,
            child: state.upcomingReleases.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming releases',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 16.w),
                    itemCount: state.upcomingReleases.length,
                    itemBuilder: (context, index) {
                      final media = state.upcomingReleases[index];
                      return UpcomingMediaCard(
                        media: media,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            media.isTvShow
                                ? Routes.tvShowDetails
                                : Routes.movieDetails,
                            arguments: media.id,
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
