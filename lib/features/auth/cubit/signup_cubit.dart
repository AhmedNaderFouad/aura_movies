import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../data/services/auth_service.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(const SignupInitial());

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      emit(const SignupLoading());

      // Call the signup use case
      await AuthService.signupUseCase.call(
        email: email,
        password: password,
        fullName: fullName,
        rememberMe: rememberMe,
      );

      emit(const SignupSuccess());
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> signUpWithGoogle({bool rememberMe = true}) async {
    try {
      emit(const SignupLoading());

      // Call the google sign in use case
      await AuthService.googleSignInUseCase.call(rememberMe: rememberMe);

      emit(const SignupSuccess());
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> signUpWithApple({bool rememberMe = true}) async {
    try {
      emit(const SignupLoading());

      // Call the apple sign in use case
      await AuthService.appleSignInUseCase.call(rememberMe: rememberMe);

      emit(const SignupSuccess());
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
        emit(const SignupNoInternet());
        return;
      }
    } else if (e is SocketException) {
      emit(const SignupNoInternet());
      return;
    }
    emit(SignupError(e.toString()));
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        emit(const SignupNoInternet());
      } else {
        emit(const SignupInitial());
      }
    } on SocketException catch (_) {
      emit(const SignupNoInternet());
    } catch (_) {
      emit(const SignupNoInternet());
    }
  }

  void reset() {
    emit(const SignupInitial());
  }
}
