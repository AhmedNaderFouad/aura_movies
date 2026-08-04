import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../data/services/auth_service.dart';

abstract class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess();
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
}

class ForgotPasswordNoInternet extends ForgotPasswordState {
  const ForgotPasswordNoInternet();
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordInitial());

  Future<void> resetPassword({required String email}) async {
    try {
      emit(const ForgotPasswordLoading());

      // Call the forgot password use case
      await AuthService.forgotPasswordUseCase.call(email: email);

      emit(const ForgotPasswordSuccess());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(const ForgotPasswordNoInternet());
      } else {
        emit(ForgotPasswordError(e.toString()));
      }
    } on SocketException {
      emit(const ForgotPasswordNoInternet());
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        emit(const ForgotPasswordNoInternet());
      } else {
        emit(const ForgotPasswordInitial());
      }
    } on SocketException catch (_) {
      emit(const ForgotPasswordNoInternet());
    } catch (_) {
      emit(const ForgotPasswordNoInternet());
    }
  }

  void reset() {
    emit(const ForgotPasswordInitial());
  }
}
