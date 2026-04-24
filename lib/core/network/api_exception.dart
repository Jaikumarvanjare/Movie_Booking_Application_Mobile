import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.isConfigurationError = false,
  });

  factory ApiException.fromDioException(DioException error) {
    final responseData = error.response?.data;
    final responseMap = responseData is Map<String, dynamic>
        ? responseData
        : responseData is Map
        ? Map<String, dynamic>.from(responseData)
        : null;
    final statusCode = error.response?.statusCode;
    final backendMessage = responseMap?['message'];
    final backendError = responseMap?['err'];

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'The server took too long to respond. Please try again.',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message:
            'Could not reach the server. Check your network and API_BASE_URL.',
        statusCode: statusCode,
      );
    }

    return ApiException(
      message: _messageForStatusCode(
        statusCode,
        fallback: buildApiErrorMessage(
          primaryMessage: backendMessage is String ? backendMessage : '',
          errorDetails: backendError,
          defaultMessage: 'Something went wrong. Please try again.',
        ),
      ),
      statusCode: statusCode,
    );
  }

  factory ApiException.configuration(String message) {
    return ApiException(message: message, isConfigurationError: true);
  }

  final String message;
  final int? statusCode;
  final bool isConfigurationError;

  @override
  String toString() => message;
}

String buildApiErrorMessage({
  required String primaryMessage,
  required Object? errorDetails,
  required String defaultMessage,
}) {
  final baseMessage = primaryMessage.trim().isEmpty
      ? defaultMessage
      : primaryMessage.trim();
  final detail = _extractErrorDetail(errorDetails);
  if (detail == null || detail == baseMessage) {
    return baseMessage;
  }
  if (_isGenericBackendMessage(baseMessage)) {
    return detail;
  }
  return '$baseMessage. $detail';
}

String _messageForStatusCode(int? statusCode, {required String fallback}) {
  switch (statusCode) {
    case 400:
      return fallback;
    case 401:
      return fallback == 'Something went wrong. Please try again.'
          ? 'Your session is unauthorized. Please sign in again.'
          : fallback;
    case 402:
      return _isGenericBackendMessage(fallback)
          ? 'Payment could not be completed. Please try again.'
          : fallback;
    case 403:
      return _isGenericBackendMessage(fallback)
          ? 'You do not have permission to perform this action.'
          : fallback;
    case 404:
      return _isGenericBackendMessage(fallback)
          ? 'The requested resource was not found.'
          : fallback;
    case 410:
      return _isGenericBackendMessage(fallback)
          ? 'This booking session has expired. Please start again.'
          : fallback;
    case 500:
      return _isGenericBackendMessage(fallback)
          ? 'The server ran into a problem. Please try again shortly.'
          : fallback;
    default:
      return fallback;
  }
}

String? _extractErrorDetail(Object? errorDetails) {
  if (errorDetails == null) {
    return null;
  }

  if (errorDetails is String) {
    final detail = errorDetails.trim();
    return detail.isEmpty ? null : detail;
  }

  if (errorDetails is List) {
    for (final item in errorDetails) {
      final detail = _extractErrorDetail(item);
      if (detail != null) {
        return detail;
      }
    }
    return null;
  }

  if (errorDetails is Map) {
    final map = errorDetails.map(
      (key, value) => MapEntry('$key', value),
    );
    for (final key in const [
      'message',
      'msg',
      'error',
      'description',
      'reason',
      'details',
    ]) {
      final detail = _extractErrorDetail(map[key]);
      if (detail != null) {
        return detail;
      }
    }
  }

  final detail = '$errorDetails'.trim();
  return detail.isEmpty ? null : detail;
}

bool _isGenericBackendMessage(String message) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }

  return normalized.contains('something went wrong') ||
      normalized.contains('cannot process the request') ||
      normalized.contains('request could not be completed') ||
      normalized.contains('please try again');
}
