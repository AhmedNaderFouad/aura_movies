import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_content.dart';
import '../widgets/home_loading_widget.dart';
import '../../../watchlist/presentation/cubit/watchlist_cubit.dart';

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
                    // Handle navigation
                    if (index == 1) {
                      Navigator.pushNamed(context, Routes.search);
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
      return const HomeLoadingWidget();
    }
    if (state is HomeSuccess) {
      return HomeContent(state: state);
    }
    if (state is HomeError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.white)),
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
}
