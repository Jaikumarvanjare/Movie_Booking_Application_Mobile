import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/auth_session.dart';
import '../features/auth/presentation/admin_users_screen.dart';
import '../features/bookings/presentation/my_bookings_screen.dart';
import '../features/movies/data/movie.dart';
import '../features/movies/data/movie_repository.dart';
import '../features/movies/presentation/admin_movies_screen.dart';
import '../features/movies/presentation/home_screen.dart';
import '../features/payments/presentation/payment_history_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shows/presentation/admin_shows_screen.dart';
import '../features/theatres/data/theatre.dart';
import '../features/theatres/presentation/admin_theatres_screen.dart';
import '../features/theatres/data/theatre_repository.dart';

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
      icon: Icon(Icons.theaters_outlined),
      selectedIcon: Icon(Icons.theaters_rounded),
      label: 'Theatres',
    ),
    NavigationDestination(
      icon: Icon(Icons.confirmation_number_outlined),
      selectedIcon: Icon(Icons.confirmation_number_rounded),
      label: 'Bookings',
    ),
    NavigationDestination(
      icon: Icon(Icons.payments_outlined),
      selectedIcon: Icon(Icons.payments_rounded),
      label: 'Payments',
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
      const CustomerTheatresScreen(),
      MyBookingsScreen(
        onBrowseMovies: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      const PaymentHistoryScreen(),
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
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF020617)],
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

class CustomerTheatresScreen extends StatefulWidget {
  const CustomerTheatresScreen({super.key});

  @override
  State<CustomerTheatresScreen> createState() => _CustomerTheatresScreenState();
}

class _CustomerTheatresScreenState extends State<CustomerTheatresScreen> {
  final _cityController = TextEditingController();
  late Future<List<Theatre>> _theatresFuture;
  late Future<List<Movie>> _moviesFuture;
  String? _selectedMovieId;

  @override
  void initState() {
    super.initState();
    _moviesFuture = context.read<MovieRepository>().fetchMovies();
    _theatresFuture = _loadTheatres();
  }

  Future<List<Theatre>> _loadTheatres() {
    return context.read<TheatreRepository>().fetchTheatres(
      movieId: _selectedMovieId,
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
    );
  }

  Future<void> _refreshTheatres() async {
    final future = _loadTheatres();
    setState(() {
      _theatresFuture = future;
    });
    await future;
  }

  void _applyFilters() {
    setState(() {
      _theatresFuture = _loadTheatres();
    });
  }

  void _clearFilters() {
    _cityController.clear();
    setState(() {
      _selectedMovieId = null;
      _theatresFuture = _loadTheatres();
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CustomerListScaffold<Theatre>(
      title: 'Theatres',
      subtitle: 'Search venues by city and movie availability.',
      future: _theatresFuture,
      onRefresh: _refreshTheatres,
      emptyTitle: 'No theatres found',
      headerChild: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          return _TheatreSearchCard(
            cityController: _cityController,
            movies: snapshot.data ?? const <Movie>[],
            selectedMovieId: _selectedMovieId,
            onMovieChanged: (movieId) {
              setState(() {
                _selectedMovieId = movieId;
              });
              _applyFilters();
            },
            onApply: _applyFilters,
            onClear: _clearFilters,
          );
        },
      ),
      itemBuilder: (context, theatre) => _DarkInfoCard(
        icon: Icons.theaters_rounded,
        title: theatre.name,
        subtitle: [
          theatre.city,
          theatre.address,
        ].where((value) => (value ?? '').trim().isNotEmpty).join(' - '),
        meta: 'Pincode ${theatre.pincode}',
      ),
    );
  }
}

class _CustomerListScaffold<T> extends StatelessWidget {
  const _CustomerListScaffold({
    required this.title,
    required this.subtitle,
    required this.future,
    required this.onRefresh,
    required this.emptyTitle,
    required this.itemBuilder,
    this.headerChild,
  });

  final String title;
  final String subtitle;
  final Future<List<T>> future;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget? headerChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<T>>(
            future: future,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState != ConnectionState.done;
              if (isLoading && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data ?? <T>[];
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  itemCount: items.isEmpty
                      ? 2 + (headerChild == null ? 0 : 1)
                      : items.length + 1 + (headerChild == null ? 0 : 1),
                  separatorBuilder: (_, index) =>
                      SizedBox(height: index == 0 ? 18 : 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _RoleHeader(title: title, subtitle: subtitle);
                    }

                    if (headerChild != null && index == 1) {
                      return headerChild!;
                    }

                    if (items.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            emptyTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }

                    final itemIndex = index - 1 - (headerChild == null ? 0 : 1);
                    return itemBuilder(context, items[itemIndex]);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TheatreSearchCard extends StatelessWidget {
  const _TheatreSearchCard({
    required this.cityController,
    required this.movies,
    required this.selectedMovieId,
    required this.onMovieChanged,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController cityController;
  final List<Movie> movies;
  final String? selectedMovieId;
  final ValueChanged<String?> onMovieChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              onSubmitted: (_) => onApply(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedMovieId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Movie',
                prefixIcon: Icon(Icons.local_movies_outlined),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All movies'),
                ),
                for (final movie in movies)
                  DropdownMenuItem<String>(
                    value: movie.id,
                    child: Text(movie.name),
                  ),
              ],
              onChanged: onMovieChanged,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Search'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkInfoCard extends StatelessWidget {
  const _DarkInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFE2E8F0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle.isEmpty ? meta : subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              meta,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
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
            color: const Color(0xFFE2E8F0),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF94A3B8),
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
                      color: const Color(0xFFE2E8F0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
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
