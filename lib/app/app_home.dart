import 'package:flutter/material.dart';

import '../features/auth/data/auth_session.dart';
import '../features/auth/presentation/admin_users_screen.dart';
import '../features/bookings/presentation/my_bookings_screen.dart';
import '../features/movies/presentation/admin_movies_screen.dart';
import '../features/movies/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shows/presentation/admin_shows_screen.dart';
import '../features/theatres/presentation/admin_theatres_screen.dart';

Widget buildHomeForUser(AppUser user) {
  switch (user.role) {
    case AppUserRole.customer:
      return const CustomerShell();
    case AppUserRole.client:
      return const ClientShell();
    case AppUserRole.admin:
      return const AdminShell();
  }
}

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.local_movies_outlined),
      selectedIcon: Icon(Icons.local_movies_rounded),
      label: 'Movies',
    ),
    NavigationDestination(
      icon: Icon(Icons.confirmation_number_outlined),
      selectedIcon: Icon(Icons.confirmation_number_rounded),
      label: 'Tickets',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      MyBookingsScreen(
        onBrowseMovies: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.local_movies_outlined),
      selectedIcon: Icon(Icons.local_movies_rounded),
      label: 'Movies',
    ),
    NavigationDestination(
      icon: Icon(Icons.theaters_outlined),
      selectedIcon: Icon(Icons.theaters_rounded),
      label: 'Theatres',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_outlined),
      selectedIcon: Icon(Icons.event_rounded),
      label: 'Shows',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _RoleDashboardScreen(
        title: 'Client Home',
        subtitle: 'Manage theatre operations from mobile.',
        cards: [
          _RoleActionCardData(
            icon: Icons.theaters_rounded,
            title: 'Theatres',
            subtitle: 'Create and update theatre details',
          ),
          _RoleActionCardData(
            icon: Icons.event_rounded,
            title: 'Shows',
            subtitle: 'Schedule shows and review seat capacity',
          ),
        ],
      ),
      const AdminMoviesScreen(),
      const AdminTheatresScreen(),
      const AdminShowsScreen(),
      const ProfileScreen(),
    ];

    return _BottomNavShell(
      selectedIndex: _selectedIndex,
      screens: screens,
      destinations: _destinations,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.admin_panel_settings_outlined),
      selectedIcon: Icon(Icons.admin_panel_settings_rounded),
      label: 'Admin',
    ),
    NavigationDestination(
      icon: Icon(Icons.local_movies_outlined),
      selectedIcon: Icon(Icons.local_movies_rounded),
      label: 'Movies',
    ),
    NavigationDestination(
      icon: Icon(Icons.theaters_outlined),
      selectedIcon: Icon(Icons.theaters_rounded),
      label: 'Theatres',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_outlined),
      selectedIcon: Icon(Icons.event_rounded),
      label: 'Shows',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline_rounded),
      selectedIcon: Icon(Icons.people_rounded),
      label: 'Users',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _RoleDashboardScreen(
        title: 'Admin Home',
        subtitle: 'Manage CineBook catalogue, venues, shows, and users.',
        cards: [
          _RoleActionCardData(
            icon: Icons.local_movies_rounded,
            title: 'Movies',
            subtitle: 'Create and update movie catalogue',
          ),
          _RoleActionCardData(
            icon: Icons.theaters_rounded,
            title: 'Theatres',
            subtitle: 'Manage venues and movie mapping',
          ),
          _RoleActionCardData(
            icon: Icons.event_rounded,
            title: 'Shows',
            subtitle: 'Schedule shows and pricing',
          ),
          _RoleActionCardData(
            icon: Icons.people_rounded,
            title: 'Users',
            subtitle: 'Review user roles and status',
          ),
        ],
      ),
      const AdminMoviesScreen(),
      const AdminTheatresScreen(),
      const AdminShowsScreen(),
      const AdminUsersScreen(),
      const ProfileScreen(),
    ];

    return _BottomNavShell(
      selectedIndex: _selectedIndex,
      screens: screens,
      destinations: _destinations,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

class _BottomNavShell extends StatelessWidget {
  const _BottomNavShell({
    required this.selectedIndex,
    required this.screens,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<Widget> screens;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}

class _RoleDashboardScreen extends StatelessWidget {
  const _RoleDashboardScreen({
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  final String title;
  final String subtitle;
  final List<_RoleActionCardData> cards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B8), Color(0xFFFFF4E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _RoleHeader(title: title, subtitle: subtitle);
              }
              return _RoleActionCard(data: cards[index - 1], theme: theme);
            },
            separatorBuilder: (_, index) =>
                SizedBox(height: index == 0 ? 18 : 12),
            itemCount: cards.length + 1,
          ),
        ),
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RoleActionCardData {
  const _RoleActionCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _RoleActionCard extends StatelessWidget {
  const _RoleActionCard({required this.data, required this.theme});

  final _RoleActionCardData data;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(data.icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF2A2118),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C4630),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
