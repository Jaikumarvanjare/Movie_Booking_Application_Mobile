import 'dart:convert';

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
    this.tokenExpiresAt,
  });

  final String token;
  final String? userId;
  final String email;
  final String name;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? tokenExpiresAt;

  bool get isExpired {
    final expiresAt = tokenExpiresAt;
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiresAt.toUtc());
  }
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
  static const _tokenExpiresAtKey = 'auth_token_expires_at';

  Future<void> saveSession(StoredSession session) async {
    final tokenExpiresAt =
        session.tokenExpiresAt ?? _readJwtExpiry(session.token);

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
    await _secureStorage.write(
      key: _tokenExpiresAtKey,
      value: tokenExpiresAt?.toIso8601String(),
    );
  }

  Future<StoredSession?> readSession() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final email = await _secureStorage.read(key: _emailKey);
    final name = await _secureStorage.read(key: _nameKey);
    final role = await _secureStorage.read(key: _roleKey);
    final status = await _secureStorage.read(key: _statusKey);
    final createdAt = await _secureStorage.read(key: _createdAtKey);
    final storedTokenExpiresAt = await _secureStorage.read(
      key: _tokenExpiresAtKey,
    );

    if (token == null ||
        email == null ||
        name == null ||
        role == null ||
        status == null) {
      return null;
    }

    final tokenExpiresAt =
        DateTime.tryParse(storedTokenExpiresAt ?? '') ?? _readJwtExpiry(token);
    final session = StoredSession(
      token: token,
      userId: await _secureStorage.read(key: _userIdKey),
      email: email,
      name: name,
      role: role,
      status: status,
      createdAt: DateTime.tryParse(createdAt ?? ''),
      tokenExpiresAt: tokenExpiresAt,
    );

    if (session.isExpired) {
      await clearSession();
      return null;
    }

    if (storedTokenExpiresAt == null && tokenExpiresAt != null) {
      await _secureStorage.write(
        key: _tokenExpiresAtKey,
        value: tokenExpiresAt.toIso8601String(),
      );
    }

    return session;
  }

  Future<String?> readToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) {
      return null;
    }

    final storedTokenExpiresAt = await _secureStorage.read(
      key: _tokenExpiresAtKey,
    );
    final tokenExpiresAt =
        DateTime.tryParse(storedTokenExpiresAt ?? '') ?? _readJwtExpiry(token);
    if (tokenExpiresAt != null &&
        DateTime.now().toUtc().isAfter(tokenExpiresAt.toUtc())) {
      await clearSession();
      return null;
    }

    return token;
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _nameKey);
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _statusKey);
    await _secureStorage.delete(key: _createdAtKey);
    await _secureStorage.delete(key: _tokenExpiresAtKey);
  }
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
