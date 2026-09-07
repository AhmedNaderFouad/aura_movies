import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../cubit/search_cubit.dart';
import '../utils/search_constants.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_mode_toggle.dart';
import '../widgets/categories_filter_section.dart';
import '../widgets/search_results_list.dart';
import '../widgets/search_empty_widget.dart';
import '../widgets/search_initial_widget.dart';
import '../widgets/search_loading_widget.dart';
import '../widgets/categories_initial_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  SearchMode _currentMode = SearchMode.keyword;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    // Clear previous search results when entering search screen
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SearchCubit>().clearSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _unfocus() {
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _unfocus();
        }
      },
      child: GestureDetector(
        onTap: _unfocus,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // 1. Search Mode Toggle (Fixed at top)
              SearchModeToggle(
                currentMode: _currentMode,
                onModeChanged: (mode) {
                  setState(() {
                    _currentMode = mode;
                  });
                  context.read<SearchCubit>().resetFilters();
                },
              ),

              // 2. Main Discovery / Search Area
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    final bool isSuccess = state is SearchSuccess;

                    return Stack(
                      children: [
                        CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // Header (SearchBar / Filters)
                            SliverToBoxAdapter(child: _buildHeaderWidget()),

                            // Content (Results or Centered Messages)
                            if (isSuccess) ...[
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                sliver: SliverToBoxAdapter(
                                  child: _buildResultsSection(state),
                                ),
                              ),
                              // Spacer for the sticky button
                              if (state.isDiscover)
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 100),
                                ),
                            ] else
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    child: _buildResultsSection(state),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Sticky Button layer
                        if (isSuccess && state.isDiscover)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildStickyButton(state.results),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWidget() {
    if (_currentMode == SearchMode.keyword) {
      return SearchBarWidget(
        key: const ValueKey('keyword_search'),
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (query) {
          context.read<SearchCubit>().searchMovies(query);
        },
        onSubmitted: (query) {
          final state = context.read<SearchCubit>().state;
          if (state is SearchSuccess && state.results.isNotEmpty) {
            Navigator.pushNamed(
              context,
              Routes.viewAllMedia,
              arguments: {'title': 'Search Results', 'list': state.results},
            );
          }
        },
        onClear: () {
          _searchController.clear();
          context.read<SearchCubit>().clearSearch();
        },
      );
    } else {
      return CategoriesFilterSection(
        key: const ValueKey('categories_search'),
        selectedMediaType: context.watch<SearchCubit>().selectedMediaType,
        selectedGenreId: context.watch<SearchCubit>().selectedGenreId,
        selectedLanguage: context.watch<SearchCubit>().selectedLanguage,
        selectedYear: context.watch<SearchCubit>().selectedYear,
        selectedCompanyId: context.watch<SearchCubit>().selectedCompanyId,
        onMediaTypeChanged: (type) {
          context.read<SearchCubit>().setMediaType(type);
        },
        onGenreChanged: (id) {
          context.read<SearchCubit>().setGenre(id);
        },
        onLanguageChanged: (lang) {
          context.read<SearchCubit>().setLanguage(lang);
        },
        onYearChanged: (year) {
          context.read<SearchCubit>().setYear(year);
        },
        onCompanyChanged: (id) {
          context.read<SearchCubit>().setCompany(id);
        },
      );
    }
  }

  Widget _buildResultsSection(SearchState state) {
    if (state is SearchInitial) {
      return _currentMode == SearchMode.keyword
          ? const SearchInitialWidget()
          : const CategoriesInitialWidget();
    } else if (state is SearchLoading) {
      return const SearchLoadingWidget();
    } else if (state is SearchSuccess) {
      final bool isAllMedia =
          context.read<SearchCubit>().selectedMediaType == 'all';
      return SearchResultsList(
        results: state.results,
        showMediaType: isAllMedia,
      );
    } else if (state is SearchEmpty) {
      return const SearchEmptyWidget();
    } else if (state is SearchError) {
      return Text(
        'Error: ${state.message}',
        style: const TextStyle(color: Colors.white),
      );
    } else if (state is SearchNoInternet) {
      return NoInternetWidget(
        onRetry: () {
          if (_currentMode == SearchMode.keyword) {
            context.read<SearchCubit>().searchMovies(_searchController.text);
          } else {
            context.read<SearchCubit>().performDiscover();
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStickyButton(List<dynamic> results) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F14), // Solid dark background
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00FFAB), // Bright Neon Green
              Color(0xFF00C3FF), // Bright Blue Cyan
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFAB).withValues(alpha: 0.35),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.viewAllMedia,
              arguments: {'title': 'Search Results', 'list': results},
            );
          },
          child: Text(
            'View Full Results',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: Text(
        'Search',
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
}
