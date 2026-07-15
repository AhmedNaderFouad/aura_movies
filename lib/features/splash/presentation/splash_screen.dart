import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/routing/routes.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/data/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check if user is already logged in
      final isLoggedIn = await AuthService.repository.isUserLoggedIn();

      // Wait for 3 seconds for splash display
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        // Navigate based on login status
        if (isLoggedIn) {
          AppRouter.pushReplacementNamed(Routes.home);
        } else {
          AppRouter.pushReplacementNamed(Routes.login);
        }
      }
    } catch (e) {
      // On error, navigate to login
      if (mounted) {
        AppRouter.pushReplacementNamed(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Main content - centered
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Movie icon
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.movie_creation_outlined,
                    color: AppColors.background,
                    size: 48.r,
                  ),
                ),
                SizedBox(height: 40.h),
                // App name
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Aura',
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontWeight: AppFonts.bold,
                          fontSize: 48.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: 'Movies',
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontWeight: AppFonts.bold,
                          fontSize: 48.sp,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ).createShader(Rect.fromLTWH(0, 0, 250.w, 100.h)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Tagline
                Text(
                  'THE CINEMA IN YOUR POCKET',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 56.h),
                // Loading bar
                SizedBox(
                  width: 80.w,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 4.h,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Powered by
            Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Text(
                'POWERED BY AURA MOVIES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
