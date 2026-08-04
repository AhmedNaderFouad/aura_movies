import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aura_movies/core/theme/app_colors.dart';
import 'package:aura_movies/core/widgets/custom_app_bar.dart';
import 'package:aura_movies/core/widgets/app_back_button.dart';
import 'package:aura_movies/core/widgets/custom_snackbar.dart';
import 'package:aura_movies/core/routing/routes.dart';
import '../../domain/entities/movie_credits.dart';
import '../../../home/domain/entities/movie.dart';
import '../../domain/entities/movie_details.dart';
import '../../../watchlist/presentation/cubit/watchlist_cubit.dart';
import '../../../watchlist/presentation/cubit/watchlist_state.dart';
import '../cubit/movie_details_cubit.dart';
import '../widgets/action_buttons_widget.dart';
import '../widgets/cast_section_widget.dart';
import '../widgets/details_section_widget.dart';
import '../widgets/director_section_widget.dart';
import '../widgets/movie_details_header_widget.dart';
import '../widgets/movie_info_section_widget.dart';
import '../widgets/shimmer_loading_widget.dart';
import '../widgets/synopsis_section_widget.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/utils/watch_now_handler.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailsCubit>().loadMovieDetails(widget.movieId);
    context.read<WatchlistCubit>().loadWatchlist();
  }

  Movie _convertToMovie(MovieDetails details) {
    return Movie(
      id: details.id,
      title: details.title,
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
      overview: details.overview,
      voteAverage: details.voteAverage,
      voteCount: details.voteCount,
      releaseDate: details.releaseDate,
      genreIds: details.genres.map((g) => g.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const AppBackButton(),
        title: const CustomAppBar(),
        centerTitle: true,
      ),
      body: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
        builder: (context, state) {
          if (state is MovieDetailsLoading) {
            return _buildLoadingWidget();
          } else if (state is MovieDetailsLoaded) {
            final movieDetails = state.movieDetails;
            final credits = state.credits;

            // Get the director from crew
            CrewMemberEntity? director;
            if (credits != null && credits.crew.isNotEmpty) {
              director = credits.crew.firstWhere(
                (member) => member.job == 'Director',
                orElse: () => credits.crew.first,
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with backdrop
                  MovieDetailsHeaderWidget(movieDetails: movieDetails),
                  SizedBox(height: 16.h),
                  // Movie Info Section
                  MovieInfoSectionWidget(movieDetails: movieDetails),
                  SizedBox(height: 12.h),
                  // Action Buttons
                  BlocConsumer<WatchlistCubit, WatchlistState>(
                    listener: (context, state) {
                      if (state is WatchlistToggleSuccess) {
                        CustomSnackBar.show(
                          context,
                          message: state.message,
                          isError: false,
                        );
                      }
                    },
                    builder: (context, watchlistState) {
                      bool isInWatchlist = false;
                      if (watchlistState is WatchlistLoaded) {
                        isInWatchlist = watchlistState.movies
                            .any((m) => m.id == widget.movieId);
                      }

                      // Check if movie is upcoming
                      bool isComingSoon = false;
                      if (movieDetails.releaseDate != null &&
                          movieDetails.releaseDate!.isNotEmpty) {
                        try {
                          final releaseDate =
                              DateTime.parse(movieDetails.releaseDate!);
                          isComingSoon = releaseDate.isAfter(DateTime.now());
                        } catch (_) {
                          // Handle parse error if necessary
                        }
                      }

                      return ActionButtonsWidget(
                        isInWatchlist: isInWatchlist,
                        isComingSoon: isComingSoon,
                        onWatchNowPressed: () {
                          WatchNowHandler.handleWatchNow(
                            context: context,
                            tmdbId: movieDetails.id.toString(),
                            imdbId: movieDetails.imdbId,
                            title: movieDetails.title,
                            isTvShow: false,
                          );
                        },
                        onAddToWatchlistPressed: () {
                          context.read<WatchlistCubit>().toggleWatchlist(
                                _convertToMovie(movieDetails),
                              );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Synopsis Section
                  SynopsisSectionWidget(
                    tagline: movieDetails.tagline,
                    overview: movieDetails.overview,
                  ),
                  SizedBox(height: 16.h),
                  // Top Cast Section - Using real data from API
                  if (credits != null && credits.cast.isNotEmpty)
                    CastSectionWidget(cast: credits.cast),
                  SizedBox(height: 12.h),
                  // Details Section
                  DetailsSectionWidget(movieDetails: movieDetails),
                  SizedBox(height: 16.h),
                  // Director Section - Using real data from API
                  if (director != null)
                    DirectorSectionWidget(director: director),
                  SizedBox(height: 50.h),
                ],
              ),
            );
          } else if (state is MovieDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.primary,
                    size: 64.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading movie details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MovieDetailsCubit>().loadMovieDetails(
                        widget.movieId,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is MovieDetailsNoInternet) {
            return Center(
              child: NoInternetWidget(
                onRetry: () => context
                    .read<MovieDetailsCubit>()
                    .loadMovieDetails(widget.movieId),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header shimmer
          ShimmerLoadingWidget(
            width: double.infinity,
            height: 280.h,
            borderRadius: 0,
          ),
          SizedBox(height: 24.h),
          // Info section shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingWidget(
                  width: 150.w,
                  height: 20.h,
                  borderRadius: 4.0,
                ),
                SizedBox(height: 16.h),
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 32.h,
                  borderRadius: 4.0,
                ),
                SizedBox(height: 16.h),
                ShimmerLoadingWidget(
                  width: 200.w,
                  height: 16.h,
                  borderRadius: 4.0,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Buttons shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 56.h,
                  borderRadius: 30.0,
                ),
                SizedBox(height: 12.h),
                ShimmerLoadingWidget(
                  width: double.infinity,
                  height: 56.h,
                  borderRadius: 30.0,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Synopsis card shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ShimmerLoadingWidget(
              width: double.infinity,
              height: 150.h,
              borderRadius: 24.0,
            ),
          ),
        ],
      ),
    );
  }
}
