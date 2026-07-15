import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordCubit>().resetPassword(
        email: _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit()..checkConnection(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordError) {
            CustomSnackBar.show(context, message: state.message, isError: true);
          } else if (state is ForgotPasswordSuccess) {
            CustomSnackBar.show(
              context,
              message: 'Password reset link sent to your email',
            );
            AppRouter.pushNamed(
              Routes.checkEmail,
              arguments: _emailController.text.trim(),
            );
          }
        },
        builder: (context, state) {
          if (state is ForgotPasswordNoInternet) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: NoInternetWidget(
                  onRetry: () =>
                      context.read<ForgotPasswordCubit>().checkConnection(),
                ),
              ),
            );
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.backgroundGradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.l,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(height: AppSpacing.xl),
                                _buildCenterIcon(),
                                SizedBox(height: AppSpacing.xl),
                                _buildTextHeader(),
                                SizedBox(height: AppSpacing.xxl),
                                _buildInputField(),
                                SizedBox(height: AppSpacing.xl),
                                BlocBuilder<
                                  ForgotPasswordCubit,
                                  ForgotPasswordState
                                >(
                                  builder: (context, stateValue) {
                                    return CustomSignInButton(
                                      text: 'Send Reset Email',
                                      onPressed: () =>
                                          _onSendResetLink(context),
                                      isLoading:
                                          stateValue is ForgotPasswordLoading,
                                    );
                                  },
                                ),
                                SizedBox(height: AppSpacing.xl),
                                _buildBottomText(),
                                SizedBox(height: AppSpacing.l),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: AppSizes.iconMedium,
            ),
            onPressed: () => AppRouter.pop(),
          ),
          SizedBox(width: AppSpacing.s),
          Text('Forgot Password', style: AppTextStyles.appBarTitle),
        ],
      ),
    );
  }

  Widget _buildCenterIcon() {
    return Container(
      width: 140.r,
      height: 140.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            color: AppColors.primary,
            size: 50.r,
          ),
        ),
      ),
    );
  }

  Widget _buildTextHeader() {
    return Column(
      children: [
        Text(
          'Forgot Password?',
          style: AppTextStyles.title.copyWith(fontSize: 32.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.m),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textFaded,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: _emailController,
          style: AppTextStyles.input,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          decoration: InputDecoration(
            hintText: 'example@gmail.com',
            hintStyle: TextStyle(color: AppColors.hintColor, fontSize: 16.sp),
            prefixIcon: Icon(
              Icons.mail_outline,
              color: AppColors.textSecondary,
              size: AppSizes.iconMedium,
            ),
            filled: true,
            fillColor: AppColors.surface.withOpacity(0.4),
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.m + AppSpacing.s,
              horizontal: AppSpacing.m,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomText() {
    return InkWell(
      onTap: () => AppRouter.pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 12.sp),
          SizedBox(width: AppSpacing.s),
          Text(
            'Back to Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
