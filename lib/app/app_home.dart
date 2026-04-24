import 'package:flutter/material.dart';

import '../features/auth/data/auth_session.dart';
import '../features/movies/presentation/home_screen.dart';

Widget buildHomeForUser(AppUser user) {
  switch (user.role) {
    case AppUserRole.customer:
      return const HomeScreen();
    case AppUserRole.client:
      return const RoleInfoScreen(
        title: 'Client tools are not available on mobile yet',
        message:
            'Use the web app for theatre and show management for now. The current mobile build is focused on the customer booking flow.',
      );
    case AppUserRole.admin:
      return const RoleInfoScreen(
        title: 'Admin tools are not available on mobile yet',
        message:
            'Use the web app for user moderation, booking monitoring, and payment monitoring until the admin mobile flow is implemented.',
      );
  }
}

class RoleInfoScreen extends StatelessWidget {
  const RoleInfoScreen({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('CineBook')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 64),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
