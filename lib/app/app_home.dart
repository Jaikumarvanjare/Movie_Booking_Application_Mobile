import 'package:flutter/material.dart';

import '../features/auth/data/auth_session.dart';
import '../features/bookings/presentation/my_bookings_screen.dart';
import '../features/movies/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

Widget buildHomeForUser(AppUser user) {
  switch (user.role) {
    case AppUserRole.customer:
    case AppUserRole.client:
    case AppUserRole.admin:
      return const CustomerShell();
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
