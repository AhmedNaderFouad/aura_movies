import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_sliding_toggle_widget.dart';
import '../cubit/discover_media_cubit.dart';
import '../cubit/discover_media_state.dart';
import '../../domain/entities/brand_entity.dart';
import '../widgets/trending_card.dart';
import '../widgets/discover_media_shimmer.dart';

class DiscoverMediaScreen extends StatefulWidget {
  final BrandEntity brand;

  const DiscoverMediaScreen({super.key, required this.brand});

  @override
  State<DiscoverMediaScreen> createState() => _DiscoverMediaScreenState();
}

class _DiscoverMediaScreenState extends State<DiscoverMediaScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isMovie = true;

  @override
  void initState() {
    super.initState();
    context.read<DiscoverMediaCubit>().loadMedia(
      widget.brand,
      isMovie: _isMovie,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DiscoverMediaCubit>().loadMedia(
        widget.brand,
        isMovie: _isMovie,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          widget.brand.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          AppSlidingToggleWidget(
            selectedIndex: _isMovie ? 0 : 1,
            options: const ['Movies', 'TV Series'],
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            onSelectedIndexChanged: (index) {
              final isMovie = index == 0;
              if (isMovie != _isMovie) {
                setState(() => _isMovie = isMovie);
                context.read<DiscoverMediaCubit>().toggleMediaType(isMovie);
              }
            },
          ),
          Expanded(
            child: BlocBuilder<DiscoverMediaCubit, DiscoverMediaState>(
              builder: (context, state) {
                if (state is DiscoverMediaSuccess ||
                    state is DiscoverMediaLoading) {
                  final media = state is DiscoverMediaSuccess
                      ? state.media
                      : (state as DiscoverMediaLoading).oldMedia;

                  if (media.isEmpty && state is DiscoverMediaSuccess) {
                    return Center(
                      child: Text(
                        'No content found',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    );
                  }

                  if (media.isEmpty &&
                      state is DiscoverMediaLoading &&
                      state.isFirstFetch) {
                    return const DiscoverMediaShimmer();
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: media.length,
                    itemBuilder: (context, index) {
                      final item = media[index];
                      return TrendingCard(
                        posterPath: item.posterPath,
                        voteAverage: item.voteAverage,
                        title: _isMovie ? item.title : item.name,
                        genreIds: item.genreIds,
                        index: index,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            _isMovie
                                ? Routes.movieDetails
                                : Routes.tvShowDetails,
                            arguments: item.id,
                          );
                        },
                      );
                    },
                  );
                }
                if (state is DiscoverMediaError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
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
}
