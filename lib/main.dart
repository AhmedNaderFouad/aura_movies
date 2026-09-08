import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aura_movies/core/theme/app_theme.dart';
import 'package:aura_movies/core/routing/app_router.dart';
import 'package:aura_movies/core/routing/on_generate_route.dart';
import 'package:aura_movies/core/routing/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aura_movies/features/auth/data/services/auth_service.dart';
import 'package:aura_movies/features/watchlist/data/services/watchlist_service.dart';
import 'package:aura_movies/features/home/presentation/cubit/home_cubit.dart';
import 'package:aura_movies/features/search/presentation/cubit/search_cubit.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:aura_movies/core/di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Auth Service
  await AuthService.initialize();
  // Initialize Watchlist Service
  await WatchlistService.initialize();

  // Initialize Service Locator
  sl.init();

  runApp(const AuraMoviesApp());
}

class AuraMoviesApp extends StatelessWidget {
  const AuraMoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AuraMovies',
          theme: AppTheme.darkTheme,
          navigatorKey: AppRouter.navigatorKey,
          onGenerateRoute: onGenerateRoute,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => HomeCubit(
                    getPopularMoviesUseCase: sl.getPopularMoviesUseCase,
                    getTopRatedMoviesUseCase: sl.getTopRatedMoviesUseCase,
                    getUpcomingMoviesUseCase: sl.getUpcomingMoviesUseCase,
                    getPopularTvShowsUseCase: sl.getPopularTvShowsUseCase,
                    getUpcomingTvShowsUseCase: sl.getUpcomingTvShowsUseCase,
                  ),
                ),
                BlocProvider(
                  create: (context) => SearchCubit(
                    searchMoviesUseCase: sl.searchMoviesUseCase,
                    discoverMoviesUseCase: sl.discoverMoviesUseCase,
                    discoverTvShowsUseCase: sl.discoverTvShowsUseCase,
                  ),
                ),
                BlocProvider(
                  create: (context) => WatchlistCubit(
                    addToWatchlistUseCase:
                        WatchlistService.addToWatchlistUseCase,
                    removeFromWatchlistUseCase:
                        WatchlistService.removeFromWatchlistUseCase,
                    getWatchlistUseCase: WatchlistService.getWatchlistUseCase,
                    isInWatchlistUseCase: WatchlistService.isInWatchlistUseCase,
                  ),
                ),
              ],
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: Routes.splash,
        );
      },
    );
  }
}
