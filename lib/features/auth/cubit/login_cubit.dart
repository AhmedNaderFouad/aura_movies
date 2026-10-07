import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:aura_movies/core/di/service_locator.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/google_signin_usecase.dart';
import '../domain/usecases/apple_signin_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AppleSignInUseCase _appleSignInUseCase;

  LoginCubit({
    LoginUseCase? loginUseCase,
    LogoutUseCase? logoutUseCase,
    GoogleSignInUseCase? googleSignInUseCase,
    AppleSignInUseCase? appleSignInUseCase,
  })  : _loginUseCase = loginUseCase ?? sl<LoginUseCase>(),
        _logoutUseCase = logoutUseCase ?? sl<LogoutUseCase>(),
        _googleSignInUseCase =
            googleSignInUseCase ?? sl<GoogleSignInUseCase>(),
        _appleSignInUseCase = appleSignInUseCase ?? sl<AppleSignInUseCase>(),
        super(const LoginInitial());

  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      emit(const LoginLoading());

      // 1. Authenticate and Fetch User
      await _loginUseCase.call(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      // Force reload user data to ensure absolute latest status from Firebase
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        // 2. Email Verification Check
        if (user != null && !user.emailVerified) {
          // Immediately trigger sign out if not verified
          await _logoutUseCase.call();
          emit(const LoginEmailNotVerified());
          return;
        }
      }

      emit(const LoginSuccess());
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> signInWithGoogle({bool rememberMe = true}) async {
    try {
      emit(const LoginLoading());

      // Call the google sign in use case
      await _googleSignInUseCase.call(rememberMe: rememberMe);

      emit(const LoginSuccess());
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> signInWithApple({bool rememberMe = true}) async {
    try {
      emit(const LoginLoading());

      // Call the apple sign in use case
      await _appleSignInUseCase.call(rememberMe: rememberMe);

      emit(const LoginSuccess());
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(const LoginNoInternet());
        return;
      }
    } else if (e is SocketException) {
      emit(const LoginNoInternet());
      return;
    }
    emit(LoginError(e.toString()));
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        emit(const LoginNoInternet());
      } else {
        emit(const LoginInitial());
      }
    } on SocketException catch (_) {
      emit(const LoginNoInternet());
    } catch (_) {
      emit(const LoginNoInternet());
    }
  }

  void reset() {
    emit(const LoginInitial());
  }

  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      // Temporarily sign in to get the user object for resending
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Silent error for resend
    }
  }
}
