import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'auth_session.dart';

class AuthApiService {
  const AuthApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/signin',
      data: {'email': email, 'password': password},
    );

    return _sessionFromResponse(response);
  }

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/signup',
      data: {'name': name, 'email': email, 'password': password},
    );

    return response.message.isEmpty
        ? 'Account created successfully. Please sign in.'
        : response.message;
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    return response.message.isEmpty
        ? 'OTP sent to your email.'
        : response.message;
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/reset-password',
      data: {'email': email, 'otp': otp, 'newPassword': newPassword},
    );

    return response.message.isEmpty
        ? 'Password updated successfully. Please sign in.'
        : response.message;
  }

  Future<AppUser> fetchProfile() async {
    final response = await _apiClient.get('/users/me');
    return _userFromResponse(
      response,
      emptyDataMessage: 'The profile response did not include account details.',
    );
  }

  Future<AppUser> updateProfile({required String name}) async {
    final response = await _apiClient.patch('/users/me', data: {'name': name});
    return _userFromResponse(
      response,
      emptyDataMessage:
          'The updated profile response did not include account details.',
    );
  }

  Future<AppUser> updateUser(
    String id, {
    AppUserRole? role,
    String? status,
  }) async {
    final payload = <String, dynamic>{};
    if (role != null) {
      payload['userRole'] = role.name.toUpperCase();
    }
    if (status != null) {
      payload['userStatus'] = status;
    }

    final response = await _apiClient.patch('/user/$id', data: payload);
    return _userFromResponse(
      response,
      emptyDataMessage:
          'The updated user response did not include account details.',
    );
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );

    return response.message.isEmpty
        ? 'Password changed successfully'
        : response.message;
  }

  Future<String> logout() async {
    final response = await _apiClient.post('/auth/logout');
    return response.message.isEmpty
        ? 'Logged out successfully'
        : response.message;
  }
}

AuthSession _sessionFromResponse(ApiResponse response) {
  final data = _readResponseMap(
    response,
    emptyDataMessage: 'The login response did not include account details.',
  );

  final token = _readFirstString(data, const ['token', 'accessToken', 'jwt']);
  final user = _userFromPayload(data);

  if (token == null) {
    throw const ApiException(
      message: 'The login response is missing token or email data.',
    );
  }

  return AuthSession(
    token: token,
    user: user,
    expiresAt: _readJwtExpiry(token),
  );
}

AppUser _userFromResponse(
  ApiResponse response, {
  required String emptyDataMessage,
}) {
  final data = _readResponseMap(response, emptyDataMessage: emptyDataMessage);
  return _userFromPayload(data);
}

Map<String, dynamic> _readResponseMap(
  ApiResponse response, {
  required String emptyDataMessage,
}) {
  final rawData = response.data;
  if (rawData is Map<String, dynamic>) {
    return rawData;
  }
  if (rawData is Map) {
    return Map<String, dynamic>.from(rawData);
  }

  throw ApiException(message: emptyDataMessage);
}

AppUser _userFromPayload(Map<String, dynamic> data) {
  final nestedUser = data['user'];
  final user = nestedUser is Map
      ? Map<String, dynamic>.from(nestedUser)
      : Map<String, dynamic>.from(data);
  final email =
      _readFirstString(user, const ['email']) ??
      _readFirstString(data, const ['email']);

  if (email == null) {
    throw const ApiException(
      message: 'The account response is missing email data.',
    );
  }

  final createdAt =
      _readFirstString(user, const ['createdAt']) ??
      _readFirstString(data, const ['createdAt']);

  return AppUser(
    id: _readFirstString(user, const ['id', '_id']),
    email: email,
    name:
        _readFirstString(user, const ['name']) ??
        _readFirstString(data, const ['name']) ??
        email,
    role: appUserRoleFromString(
      _readFirstString(user, const ['role', 'userRole']) ??
          _readFirstString(data, const ['role', 'userRole']) ??
          'CUSTOMER',
    ),
    status:
        _readFirstString(user, const ['status', 'userStatus']) ??
        _readFirstString(data, const ['status', 'userStatus']) ??
        'APPROVED',
    createdAt: DateTime.tryParse(createdAt ?? ''),
  );
}

String? _readFirstString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}

DateTime? _readJwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length < 2) {
    return null;
  }

  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final json = jsonDecode(payload);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final exp = json['exp'];
    if (exp is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    }
  } catch (_) {
    return null;
  }

  return null;
}
