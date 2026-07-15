import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/utils/validators.dart';
import '../../cubit/login_cubit.dart';
import '../../cubit/login_state.dart';
import '../widgets/social_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/routing/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit()..checkConnection(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginError) {
            CustomSnackBar.show(context, message: state.message, isError: true);
          } else if (state is LoginEmailNotVerified) {
            CustomSnackBar.show(
              context,
              message:
                  'Please verify your email first. A verification link has been sent to your inbox/spam.',
              isError: true,
              actionLabel: 'Resend',
              onAction: () => context.read<LoginCubit>().resendVerificationEmail(
                    _emailController.text.trim(),
                    _passwordController.text,
                  ),
            );
          } else if (state is LoginSuccess) {
            CustomSnackBar.show(context, message: 'Login Successful');
            // Navigate to Home on success
            AppRouter.pushReplacementNamed(Routes.home);
          }
        },
        builder: (context, state) {
          if (state is LoginNoInternet) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: NoInternetWidget(
                  onRetry: () => context.read<LoginCubit>().checkConnection(),
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              backgroundColor: AppColors.background,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Transform.scale(
                    scale: 1.4,
                    child: Image.asset(
                      'assets/images/bg_img.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, 0.3),
                      color: Colors.black.withValues(alpha: 0.5),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            _buildForm(),
                            _buildActions(context),
                            SizedBox(height: 24.h),
                            _buildSocialSection(context),
                            SizedBox(height: 32.h),
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Text(
          'Sign In',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 32.sp,
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextFormField(
          label: 'Email',
          hintText: 'Enter Your Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          prefixIcon: Icon(Icons.email_outlined, size: 22.r),
        ),
        SizedBox(height: 24.h),
        CustomTextFormField(
          label: 'Password',
          hintText: 'Enter Your Password',
          controller: _passwordController,
          obscureText: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          validator: Validators.validatePassword,
          prefixIcon: Icon(Icons.lock_outline, size: 22.r),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.hintColor,
              size: 24.r,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) {
                  setState(() => _rememberMe = val ?? false);
                },
                activeColor: AppColors.primary,
                checkColor: Colors.black,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Remember me',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
            ),
            const Spacer(),
            InkWell(
              onTap: () => AppRouter.pushNamed(Routes.forgotPassword),
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            return CustomSignInButton(
              text: 'Sign In',
              onPressed: () => _onSignIn(context),
              isLoading: state is LoginLoading,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Or Sign In with',
                style: TextStyle(color: Colors.white38, fontSize: 14.sp),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24)),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SocialButton(
              icon: Icon(Icons.apple, color: Colors.white, size: 28.r),
              text: 'Apple',
              onTap: () {
                context.read<LoginCubit>().signInWithApple(rememberMe: _rememberMe);
              },
            ),
            SocialButton(
              icon: Image.asset(
                'assets/icons/google_icon.png',
                width: 24.w,
                height: 24.h,
              ),
              text: 'Google',
              onTap: () {
                context.read<LoginCubit>().signInWithGoogle(rememberMe: _rememberMe);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white38, fontSize: 14.sp),
        ),
        InkWell(
          onTap: () => AppRouter.pushNamed(Routes.signup),
          borderRadius: BorderRadius.circular(4.r),
          child: Padding(
            padding: EdgeInsets.all(4.r),
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
