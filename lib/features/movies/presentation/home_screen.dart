import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/movie.dart';
import '../data/movie_repository.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Movie>>? _moviesFuture;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _moviesFuture = context.read<MovieRepository>().fetchMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMovies([String? query]) {
    setState(() {
      _moviesFuture = context.read<MovieRepository>().fetchMovies(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _HomeMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load movies',
                  message: '${snapshot.error}',
                  actionLabel: 'Retry',
                  onPressed: () => _loadMovies(_searchController.text),
                );
              }

              final movies = snapshot.data ?? const <Movie>[];
              final nowShowing = movies
                  .where((movie) => movie.isNowShowing)
                  .toList(growable: false);
              final featuredMovie = nowShowing.isNotEmpty
                  ? nowShowing.first
                  : movies.isNotEmpty
                  ? movies.first
                  : null;
              final comingSoon = movies
                  .where((movie) => !movie.isNowShowing)
                  .toList(growable: false);

              if (movies.isEmpty) {
                return _HomeMessageState(
                  icon: Icons.movie_filter_outlined,
                  title: 'No movies found',
                  message: _searchController.text.trim().isEmpty
                      ? 'Once the backend starts returning movie data, your catalogue will appear here.'
                      : 'Try a different movie name or clear the search.',
                  actionLabel: _searchController.text.trim().isEmpty
                      ? 'Retry'
                      : 'Clear search',
                  onPressed: () {
                    if (_searchController.text.trim().isNotEmpty) {
                      _searchController.clear();
                    }
                    _loadMovies();
                  },
                );
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: _HomeHeader(
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: _SearchField(
                        controller: _searchController,
                        colorScheme: colorScheme,
                        onSearch: _loadMovies,
                      ),
                    ),
                  ),
                  if (featuredMovie != null) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverToBoxAdapter(
                        child: _FeaturedMovieCard(
                          movie: featuredMovie,
                          theme: theme,
                          colorScheme: colorScheme,
                          onPressed: () =>
                              _openMovieDetails(context, featuredMovie),
                        ),
                      ),
                    ),
                  ],
                  if (nowShowing.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    SliverToBoxAdapter(
                      child: _HorizontalMovieSection(
                        title: 'Now showing',
                        movies: nowShowing,
                        theme: theme,
                        onMoviePressed: (movie) =>
                            _openMovieDetails(context, movie),
                      ),
                    ),
                  ],
                  if (comingSoon.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      sliver: SliverToBoxAdapter(
                        child: _ComingSoonSection(
                          movies: comingSoon,
                          theme: theme,
                          colorScheme: colorScheme,
                          onMoviePressed: (movie) =>
                              _openMovieDetails(context, movie),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
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
        ],
      ),
    );
  }

  void _openMovieDetails(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.theme, required this.colorScheme});

  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your next show',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF2A2118),
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.colorScheme,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ColorScheme colorScheme;
  final ValueChanged<String?> onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSearch,
      onChanged: (value) {
        if (value.trim().isEmpty) {
          onSearch(null);
        }
      },
      decoration: InputDecoration(
        hintText: 'Search movies by name',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () => onSearch(controller.text),
          icon: Icon(Icons.travel_explore_rounded, color: colorScheme.primary),
        ),
      ),
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard({
    required this.movie,
    required this.theme,
    required this.colorScheme,
    required this.onPressed,
  });

  final Movie movie;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [movie.primaryColor, movie.accentColor],
          ),
          boxShadow: [
            BoxShadow(
              color: movie.primaryColor.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MovieBadge(label: movie.releaseStatusLabel),
                const Spacer(),
                Icon(
                  Icons.language_rounded,
                  color: colorScheme.primaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  movie.language,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 42),
            Text(
              movie.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.releaseDateLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.tonalIcon(
              onPressed: onPressed,
              icon: const Icon(Icons.event_seat_rounded),
              label: const Text('Book tickets'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalMovieSection extends StatelessWidget {
  const _HorizontalMovieSection({
    required this.title,
    required this.movies,
    required this.theme,
    required this.onMoviePressed,
  });

  final String title;
  final List<Movie> movies;
  final ThemeData theme;
  final ValueChanged<Movie> onMoviePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(title: title, action: 'See all', theme: theme),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 210,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _MoviePosterCard(
                movie: movie,
                theme: theme,
                onPressed: () => onMoviePressed(movie),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemCount: movies.length,
          ),
        ),
      ],
    );
  }
}

class _MoviePosterCard extends StatelessWidget {
  const _MoviePosterCard({
    required this.movie,
    required this.theme,
    required this.onPressed,
  });

  final Movie movie;
  final ThemeData theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 150,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [movie.primaryColor, movie.accentColor],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: _MovieBadge(label: movie.releaseStatusLabel),
                ),
                const Spacer(),
                Icon(
                  Icons.movie_creation_outlined,
                  color: Colors.white.withValues(alpha: 0.82),
                  size: 32,
                ),
                const SizedBox(height: 14),
                Text(
                  movie.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  movie.language,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection({
    required this.movies,
    required this.theme,
    required this.colorScheme,
    required this.onMoviePressed,
  });

  final List<Movie> movies;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final ValueChanged<Movie> onMoviePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Coming soon', action: 'Remind me', theme: theme),
        const SizedBox(height: 14),
        ...movies.map(
          (movie) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                onTap: () => onMoviePressed(movie),
                contentPadding: const EdgeInsets.all(14),
                leading: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: movie.primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.live_tv_rounded, color: movie.accentColor),
                ),
                title: Text(
                  movie.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(movie.releaseDateLabel),
                trailing: Text(
                  movie.releaseStatusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.theme,
  });

  final String title;
  final String action;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF2A2118),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(onPressed: () {}, child: Text(action)),
      ],
    );
  }
}

class _MovieBadge extends StatelessWidget {
  const _MovieBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HomeMessageState extends StatelessWidget {
  const _HomeMessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
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
            const SizedBox(height: 18),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
