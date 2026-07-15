import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../cubit/forgot_password_cubit.dart';

class CheckEmailScreen extends StatelessWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  Future<void> _openEmailApp(BuildContext context) async {
    final Uri gmailUrl = Uri.parse('googlegmail:///');
    final Uri outlookUrl = Uri.parse('ms-outlook:///');
    final Uri yahooUrl = Uri.parse('ymail:///');
    final Uri appleMailUrl = Uri.parse('message:///');
    final Uri webMailUrl = Uri.parse('https://mail.google.com/');

    try {
      if (await canLaunchUrl(gmailUrl)) {
        await launchUrl(gmailUrl);
      } else if (await canLaunchUrl(outlookUrl)) {
        await launchUrl(outlookUrl);
      } else if (await canLaunchUrl(yahooUrl)) {
        await launchUrl(yahooUrl);
      } else if (await canLaunchUrl(appleMailUrl)) {
        await launchUrl(appleMailUrl);
      } else {
        // Fallback to web browser which usually prompts to open the app on Android
        final launched = await launchUrl(
          webMailUrl,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          if (context.mounted) {
            CustomSnackBar.show(
              context,
              message: "Could not find an email app.",
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: "Error opening email app.",
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            CustomSnackBar.show(
              context,
              message: 'Reset link resent successfully!',
            );
          } else if (state is ForgotPasswordError) {
            CustomSnackBar.show(context, message: state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image with dark overlay
                Transform.scale(
                  scale: 1.4,
                  child: Image.asset(
                    'assets/images/bg_img.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, 0.3),
                    color: Colors.black.withOpacity(0.75),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                // Content
                SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSizes.s24),
                          child: Column(
                            children: [
                              SizedBox(height: 60.h),
                              _buildEmailIcon(),
                              SizedBox(height: AppSizes.s40),
                              Text(
                                'Check Your Email',
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSizes.s16),
                              Text(
                                "We've sent a password reset link to $email. Please check your inbox and follow the instructions.",
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.textFaded,
                                  height: 1.5,
                                  fontSize: 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSizes.s48),
                              CustomSignInButton(
                                text: 'Open Email App',
                                onPressed: () => _openEmailApp(context),
                              ),
                              SizedBox(height: AppSizes.s16),
                              _buildResendButton(context, state),
                              SizedBox(height: AppSizes.s32),
                              _buildBackToSignIn(),
                              SizedBox(height: AppSizes.s24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: AppSizes.iconMedium,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: AppSpacing.s),
          Text(
            'AuraMovies',
            style: AppTextStyles.appBarTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailIcon() {
    return Container(
      width: 160.r,
      height: 160.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1D21),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 50,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Icon(
                Icons.mail_rounded,
                color: AppColors.primary,
                size: 70.r,
              ),
            ),
            Positioned(
              right: 35.w,
              top: 35.h,
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1A1D21), width: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendButton(BuildContext context, ForgotPasswordState state) {
    final isLoading = state is ForgotPasswordLoading;
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25282D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          ),
        ),
        onPressed: isLoading
            ? null
            : () {
                context.read<ForgotPasswordCubit>().resetPassword(email: email);
              },
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Resend Email',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToSignIn() {
    return InkWell(
      onTap: () => AppRouter.pushNamedAndRemoveUntil(Routes.login),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s),
        child: Text(
          'Back to Sign In',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
