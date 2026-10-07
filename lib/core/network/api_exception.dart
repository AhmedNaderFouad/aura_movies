import 'package:dio/dio.dart';

abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection available.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(
            'Authentication failed. Please sign in again.',
            statusCode: statusCode,
          );
        }
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            'Server error ($statusCode). Please try again later.',
            statusCode: statusCode,
          );
        }
        final message = error.response?.data?['status_message'] as String? ??
            'Request failed with status $statusCode.';
        return ServerException(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      default:
        return NetworkException(
          error.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}

class NetworkException extends ApiException {
  const NetworkException(super.message, {super.statusCode});
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.statusCode});
}

class TimeoutException extends ApiException {
  const TimeoutException(super.message, {super.statusCode});
}
