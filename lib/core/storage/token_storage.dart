import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSession {
  const StoredSession({
    required this.token,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.userId,
    this.createdAt,
  });

  final String token;
  final String? userId;
  final String email;
  final String name;
  final String role;
  final String status;
  final DateTime? createdAt;
}

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _nameKey = 'auth_name';
  static const _roleKey = 'auth_role';
  static const _statusKey = 'auth_status';
  static const _createdAtKey = 'auth_created_at';

  Future<void> saveSession(StoredSession session) async {
    await _secureStorage.write(key: _tokenKey, value: session.token);
    await _secureStorage.write(key: _userIdKey, value: session.userId);
    await _secureStorage.write(key: _emailKey, value: session.email);
    await _secureStorage.write(key: _nameKey, value: session.name);
    await _secureStorage.write(key: _roleKey, value: session.role);
    await _secureStorage.write(key: _statusKey, value: session.status);
    await _secureStorage.write(
      key: _createdAtKey,
      value: session.createdAt?.toIso8601String(),
    );
  }

  Future<StoredSession?> readSession() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final email = await _secureStorage.read(key: _emailKey);
    final name = await _secureStorage.read(key: _nameKey);
    final role = await _secureStorage.read(key: _roleKey);
    final status = await _secureStorage.read(key: _statusKey);
    final createdAt = await _secureStorage.read(key: _createdAtKey);

    if (token == null ||
        email == null ||
        name == null ||
        role == null ||
        status == null) {
      return null;
    }

    return StoredSession(
      token: token,
      userId: await _secureStorage.read(key: _userIdKey),
      email: email,
      name: name,
      role: role,
      status: status,
      createdAt: DateTime.tryParse(createdAt ?? ''),
    );
  }

  Future<String?> readToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _nameKey);
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _statusKey);
    await _secureStorage.delete(key: _createdAtKey);
  }
}
