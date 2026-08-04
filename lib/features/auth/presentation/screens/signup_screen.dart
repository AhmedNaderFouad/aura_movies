import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/utils/validators.dart';
import '../../cubit/signup_cubit.dart';
import '../../cubit/signup_state.dart';
import '../widgets/social_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/routing/app_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp(BuildContext context) {
    // 1. Strict Validation Check using Regex before calling API
    final email = _emailController.text.trim();
    final emailError = Validators.validateEmail(email);

    if (emailError != null) {
      // 2. Stop process and show dark themed SnackBar for invalid emails
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid email address',
        isError: true,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // 3. Safe Firebase Registration Trigger
      context.read<SignupCubit>().signUp(
        fullName: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit()..checkConnection(),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupError) {
            CustomSnackBar.show(context, message: state.message, isError: true);
          } else if (state is SignupSuccess) {
            CustomSnackBar.show(
              context,
              message: 'Account Created! Verification email sent.',
            );
            AppRouter.pop();
          }
        },
        builder: (context, state) {
          if (state is SignupNoInternet) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: NoInternetWidget(
                  onRetry: () => context.read<SignupCubit>().checkConnection(),
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              extendBody: true,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image - Same as Login
                  Transform.scale(
                    scale: 1.4,
                    child: Image.asset(
                      'assets/images/bg_img.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, 0.3),
                      color: Colors.black.withValues(alpha: 0.55),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AppBackButton(),
                              ),
                              CustomAppBar(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  SizedBox(height: 20.h),
                                  _buildHeader(),
                                  SizedBox(height: 32.h),
                                  _buildForm(),
                                  SizedBox(height: 32.h),
                                  _buildActions(context, state),
                                  SizedBox(height: 40.h),
                                  _buildSocialSection(context),
                                  SizedBox(height: 40.h),
                                  _buildFooter(context),
                                  SizedBox(height: 24.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 34.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Experience cinema in a whole new light.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextFormField(
          label: 'Full Name',
          hintText: 'Enter your name',
          controller: _nameController,
          prefixIcon: Icon(Icons.person_outline, size: 22.r),
          validator: Validators.validateFullName,
        ),
        SizedBox(height: 24.h),
        CustomTextFormField(
          label: 'Email Address',
          hintText: 'name@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_outlined, size: 22.r),
          validator: Validators.validateEmail,
        ),
        SizedBox(height: 24.h),
        CustomTextFormField(
          label: 'Password',
          hintText: 'Min. 8 characters',
          controller: _passwordController,
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock_outline, size: 22.r),
          validator: Validators.validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.hintColor,
              size: 24.r,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, SignupState state) {
    return CustomSignInButton(
      text: 'Create Account',
      onPressed: () => _onSignUp(context),
      isLoading: state is SignupLoading,
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white12, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'OR SIGN UP WITH',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white12, thickness: 1)),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: SocialButton(
                icon: Icon(Icons.apple, color: Colors.white, size: 24.r),
                text: 'Apple',
                onTap: () {
                  context.read<SignupCubit>().signUpWithApple();
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: SocialButton(
                icon: Image.asset('assets/icons/google_icon.png', width: 22.w),
                text: 'Google',
                onTap: () {
                  context.read<SignupCubit>().signUpWithGoogle();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        InkWell(
          onTap: () => AppRouter.pop(),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
