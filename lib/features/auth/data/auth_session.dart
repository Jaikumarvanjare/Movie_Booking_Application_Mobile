enum AppUserRole { customer, client, admin }

class AppUser {
  const AppUser({
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.id,
    this.createdAt,
  });

  final String? id;
  final String email;
  final String name;
  final AppUserRole role;
  final String status;
  final DateTime? createdAt;

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    AppUserRole? role,
    String? status,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user, this.expiresAt});

  final String token;
  final AppUser user;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  AuthSession copyWith({String? token, AppUser? user, DateTime? expiresAt}) {
    return AuthSession(
      token: token ?? this.token,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

AppUserRole appUserRoleFromString(String value) {
  switch (value.toUpperCase()) {
    case 'CLIENT':
      return AppUserRole.client;
    case 'ADMIN':
      return AppUserRole.admin;
    case 'CUSTOMER':
    default:
      return AppUserRole.customer;
  }
}
