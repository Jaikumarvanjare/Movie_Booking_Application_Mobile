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
  const AuthSession({required this.token, required this.user});

  final String token;
  final AppUser user;

  AuthSession copyWith({String? token, AppUser? user}) {
    return AuthSession(token: token ?? this.token, user: user ?? this.user);
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
