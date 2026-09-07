import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura_movies/core/constants/media_type.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/screens/check_email_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/media_details/presentation/screens/media_details_screen.dart';
import '../../features/media_details/presentation/cubit/media_details_cubit.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/watchlist/presentation/screens/watchlist_screen.dart';
import '../../features/home/presentation/screens/discover_media_screen.dart';
import '../../features/home/presentation/cubit/discover_media_cubit.dart';
import '../../features/home/domain/entities/brand_entity.dart';
import '../widgets/view_all_media_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'routes.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case Routes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case Routes.signup:
      return MaterialPageRoute(builder: (_) => const SignupScreen());
    case Routes.forgotPassword:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
    case Routes.checkEmail:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(builder: (_) => CheckEmailScreen(email: email));
    case Routes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case Routes.search:
      return MaterialPageRoute(builder: (_) => const SearchScreen());
    case Routes.watchlist:
      return MaterialPageRoute(builder: (_) => const WatchlistScreen());
    case Routes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case Routes.movieDetails:
    case Routes.tvShowDetails:
      final id = settings.arguments as int?;
      final type = settings.name == Routes.movieDetails
          ? MediaType.movie
          : MediaType.tv;
      if (id == null) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                '${type == MediaType.movie ? 'Movie' : 'TV Show'} ID is required',
              ),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => MediaDetailsCubit(
            getMediaDetailsUseCase: sl.getMediaDetailsUseCase,
            getMediaCreditsUseCase: sl.getMediaCreditsUseCase,
            getMediaRecommendationsUseCase: sl.getMediaRecommendationsUseCase,
            repository: sl.mediaDetailsRepository,
          ),
          child: MediaDetailsScreen(mediaId: id, mediaType: type),
        ),
      );
    case Routes.viewAllMedia:
      final args = settings.arguments as Map<String, dynamic>?;
      if (args == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Arguments are required')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => ViewAllMediaScreen(
          sectionTitle: args['title'] as String,
          mediaList: args['list'] as List<dynamic>,
        ),
      );
    case Routes.discoverMedia:
      final brand = settings.arguments as BrandEntity?;
      if (brand == null) {
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Brand is required'))),
        );
      }
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => DiscoverMediaCubit(
            discoverMoviesUseCase: sl.discoverMoviesUseCase,
            discoverTvShowsUseCase: sl.discoverTvShowsUseCase,
          ),
          child: DiscoverMediaScreen(brand: brand),
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
