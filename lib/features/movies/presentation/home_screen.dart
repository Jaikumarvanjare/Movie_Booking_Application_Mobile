import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _nowShowingMovies = [
    _Movie(
      title: 'Midnight Metro',
      genre: 'Action thriller',
      runtime: '2h 08m',
      rating: '4.8',
      badge: 'IMAX',
      primaryColor: Color(0xFF2A2118),
      accentColor: Color(0xFFC44536),
    ),
    _Movie(
      title: 'City of Stars',
      genre: 'Romance drama',
      runtime: '1h 54m',
      rating: '4.6',
      badge: 'Dolby',
      primaryColor: Color(0xFF683B2B),
      accentColor: Color(0xFFFFB45E),
    ),
    _Movie(
      title: 'Orbit Nine',
      genre: 'Sci-fi adventure',
      runtime: '2h 21m',
      rating: '4.9',
      badge: '3D',
      primaryColor: Color(0xFF233142),
      accentColor: Color(0xFFFFE0B8),
    ),
  ];

  static const _comingSoonMovies = [
    _Movie(
      title: 'The Last Balcony',
      genre: 'Mystery',
      runtime: 'Releasing Fri',
      rating: '92%',
      badge: 'Pre-book',
      primaryColor: Color(0xFF5C4630),
      accentColor: Color(0xFFFFF4E6),
    ),
    _Movie(
      title: 'Laugh Track Live',
      genre: 'Comedy',
      runtime: 'Releasing May 02',
      rating: '88%',
      badge: 'Alert me',
      primaryColor: Color(0xFF2F4858),
      accentColor: Color(0xFFFFB45E),
    ),
  ];

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
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _HomeHeader(theme: theme, colorScheme: colorScheme),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _SearchField(colorScheme: colorScheme),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _FeaturedMovieCard(
                    movie: _nowShowingMovies.first,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: _HorizontalMovieSection(
                  title: 'Now showing',
                  movies: _nowShowingMovies,
                  theme: theme,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverToBoxAdapter(
                  child: _ComingSoonSection(
                    movies: _comingSoonMovies,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
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
  const _SearchField({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search movies, theatres, shows',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: Icon(Icons.tune_rounded, color: colorScheme.primary),
      ),
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard({
    required this.movie,
    required this.theme,
    required this.colorScheme,
  });

  final _Movie movie;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              _MovieBadge(label: 'Featured tonight'),
              const Spacer(),
              Icon(Icons.star_rounded, color: colorScheme.primaryContainer),
              const SizedBox(width: 4),
              Text(
                movie.rating,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          Text(
            movie.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${movie.genre} • ${movie.runtime}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.event_seat_rounded),
            label: const Text('Book tickets'),
          ),
        ],
      ),
    );
  }
}

class _HorizontalMovieSection extends StatelessWidget {
  const _HorizontalMovieSection({
    required this.title,
    required this.movies,
    required this.theme,
  });

  final String title;
  final List<_Movie> movies;
  final ThemeData theme;

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
              return _MoviePosterCard(movie: movies[index], theme: theme);
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
  const _MoviePosterCard({required this.movie, required this.theme});

  final _Movie movie;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                child: _MovieBadge(label: movie.badge),
              ),
              const Spacer(),
              Icon(
                Icons.movie_creation_outlined,
                color: Colors.white.withValues(alpha: 0.82),
                size: 32,
              ),
              const SizedBox(height: 14),
              Text(
                movie.title,
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
                movie.genre,
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
    );
  }
}

class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection({
    required this.movies,
    required this.theme,
    required this.colorScheme,
  });

  final List<_Movie> movies;
  final ThemeData theme;
  final ColorScheme colorScheme;

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
                  movie.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text('${movie.genre} • ${movie.runtime}'),
                trailing: Text(
                  movie.badge,
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

class _Movie {
  const _Movie({
    required this.title,
    required this.genre,
    required this.runtime,
    required this.rating,
    required this.badge,
    required this.primaryColor,
    required this.accentColor,
  });

  final String title;
  final String genre;
  final String runtime;
  final String rating;
  final String badge;
  final Color primaryColor;
  final Color accentColor;
}
