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

  Future<String> resetPassword({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.patch(
      '/auth/reset',
      data: {'email': email, 'password': password},
    );

    return response.message.isEmpty
        ? 'Password updated successfully. Please sign in.'
        : response.message;
  }
}

AuthSession _sessionFromResponse(ApiResponse response) {
  final rawData = response.data;
  if (rawData is! Map) {
    throw const ApiException(
      message: 'The login response did not include account details.',
    );
  }

  final data = Map<String, dynamic>.from(rawData);
  final nestedUser = data['user'];
  final user = nestedUser is Map
      ? Map<String, dynamic>.from(nestedUser)
      : Map<String, dynamic>.from(data);

  final token = _readFirstString(data, const ['token', 'accessToken', 'jwt']);
  final email =
      _readFirstString(user, const ['email']) ??
      _readFirstString(data, const ['email']);

  if (token == null || email == null) {
    throw const ApiException(
      message: 'The login response is missing token or email data.',
    );
  }

  return AuthSession(
    token: token,
    user: AppUser(
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
    ),
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
