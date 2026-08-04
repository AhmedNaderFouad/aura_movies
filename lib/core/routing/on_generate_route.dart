import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/check_email_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/movie_details/presentation/screens/movie_details_screen.dart';
import '../../features/tv_show_details/presentation/screens/tv_show_details_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/watchlist/presentation/screens/watchlist_screen.dart';
import '../../features/home/presentation/screens/view_all_media_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'routes.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  // Bonus: Handle arguments if needed
  // final arguments = settings.arguments;

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
      return MaterialPageRoute(
        builder: (_) => CheckEmailScreen(email: email),
      );
    case Routes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case Routes.search:
      return MaterialPageRoute(builder: (_) => const SearchScreen());
    case Routes.watchlist:
      return MaterialPageRoute(builder: (_) => const WatchlistScreen());
    case Routes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case Routes.movieDetails:
      final movieId = settings.arguments as int?;
      if (movieId == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Movie ID is required')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movieId: movieId),
      );
    case Routes.tvShowDetails:
      final tvShowId = settings.arguments as int?;
      if (tvShowId == null) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('TV Show ID is required')),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => TVShowDetailsScreen(tvShowId: tvShowId),
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
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
