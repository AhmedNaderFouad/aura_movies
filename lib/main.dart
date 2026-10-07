import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aura_movies/core/theme/app_theme.dart';
import 'package:aura_movies/core/routing/app_router.dart';
import 'package:aura_movies/core/routing/on_generate_route.dart';
import 'package:aura_movies/core/routing/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aura_movies/features/home/presentation/cubit/home_cubit.dart';
import 'package:aura_movies/features/home/domain/usecases/get_popular_movies_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_popular_tv_shows_usecase.dart';
import 'package:aura_movies/features/home/domain/usecases/get_upcoming_tv_shows_usecase.dart';
import 'package:aura_movies/features/search/presentation/cubit/search_cubit.dart';
import 'package:aura_movies/features/search/domain/usecases/search_movies_usecase.dart';
import 'package:aura_movies/features/search/domain/usecases/discover_movies_usecase.dart';
import 'package:aura_movies/features/search/domain/usecases/discover_tv_shows_usecase.dart';
import 'package:aura_movies/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:aura_movies/features/watchlist/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:aura_movies/features/watchlist/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:aura_movies/features/watchlist/domain/usecases/get_watchlist_usecase.dart';
import 'package:aura_movies/features/watchlist/domain/usecases/is_in_watchlist_usecase.dart';
import 'package:aura_movies/core/di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Service Locator with get_it
  await initServiceLocator();

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
                    getPopularMoviesUseCase: sl<GetPopularMoviesUseCase>(),
                    getTopRatedMoviesUseCase: sl<GetTopRatedMoviesUseCase>(),
                    getUpcomingMoviesUseCase: sl<GetUpcomingMoviesUseCase>(),
                    getPopularTvShowsUseCase: sl<GetPopularTvShowsUseCase>(),
                    getUpcomingTvShowsUseCase: sl<GetUpcomingTvShowsUseCase>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => SearchCubit(
                    searchMoviesUseCase: sl<SearchMoviesUseCase>(),
                    discoverMoviesUseCase: sl<DiscoverMoviesUseCase>(),
                    discoverTvShowsUseCase: sl<DiscoverTvShowsUseCase>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => WatchlistCubit(
                    addToWatchlistUseCase: sl<AddToWatchlistUseCase>(),
                    removeFromWatchlistUseCase:
                        sl<RemoveFromWatchlistUseCase>(),
                    getWatchlistUseCase: sl<GetWatchlistUseCase>(),
                    isInWatchlistUseCase: sl<IsInWatchlistUseCase>(),
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
