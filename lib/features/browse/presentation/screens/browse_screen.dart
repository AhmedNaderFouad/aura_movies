import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../features/home/domain/entities/movie.dart';
import '../../../../features/home/domain/entities/tv_show.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../cubit/search_cubit.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Clear previous search results when entering browse screen
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SearchCubit>().clearSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          // Search Results
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _buildInitialState();
                } else if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is SearchSuccess) {
                  return _buildSearchResults(state.results);
                } else if (state is SearchEmpty) {
                  return _buildEmptyState();
                } else if (state is SearchError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else if (state is SearchNoInternet) {
                  return Center(
                    child: NoInternetWidget(
                      onRetry: () => context
                          .read<SearchCubit>()
                          .searchMovies(_searchController.text),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        'Browse',
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              onChanged: (query) {
                context.read<SearchCubit>().searchMovies(query);
                setState(() {}); // Rebuild to update suffixIcon
              },
              decoration: InputDecoration(
                hintText: 'Search movies & TV shows...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22.r,
                ),
                suffixIcon: value.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          context.read<SearchCubit>().clearSearch();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 22.r,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_rounded,
            size: 80.r,
            color: AppColors.primary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Start Exploring',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Search for your favorite movies & TV shows',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.r,
            color: AppColors.primary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildResultCard(dynamic item) {
    final bool isMovie = item is Movie;
    final String title = isMovie ? item.title : (item as TVShow).name;
    final String? posterPath = isMovie
        ? item.posterPath
        : (item as TVShow).posterPath;
    final String date = isMovie ? item.releaseDate ?? 'No date' : 'TV Series';
    final double voteAverage = isMovie
        ? item.voteAverage ?? 0.0
        : (item as TVShow).voteAverage ?? 0.0;

    return GestureDetector(
      onTap: () {
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          date,
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
