enum AppUserRole { customer, client, admin }

class AppUser {
  const AppUser({
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.id,
  });

  final String? id;
  final String email;
  final String name;
  final AppUserRole role;
  final String status;
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AppUser user;
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
