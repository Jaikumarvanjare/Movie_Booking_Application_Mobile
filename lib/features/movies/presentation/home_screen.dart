import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/session_controller.dart';
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
  String _statusFilter = 'ALL';
  String _languageFilter = 'ALL';

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
      _moviesFuture = context.read<MovieRepository>().fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstName = context
        .watch<SessionController>()
        .user
        ?.name
        .trim()
        .split(RegExp(r'\s+'))
        .first;

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
              final filteredMovies = _filterMovies(movies);
              final languages = _languagesFor(movies);
              final nowShowing = filteredMovies
                  .where((movie) => movie.isNowShowing)
                  .toList(growable: false);
              final featuredMovies = _popularMoviesForCarousel(
                filteredMovies,
                nowShowing,
              );
              final comingSoon = filteredMovies
                  .where((movie) => movie.isUpcoming)
                  .toList(growable: false);

              if (filteredMovies.isEmpty) {
                return _HomeMessageState(
                  icon: Icons.movie_filter_outlined,
                  title: 'No movies found',
                  message: _hasActiveFilters
                      ? 'Try a different movie name, language, or release filter.'
                      : 'Once the backend starts returning movie data, your catalogue will appear here.',
                  actionLabel: _hasActiveFilters ? 'Clear filters' : 'Retry',
                  onPressed: () {
                    _clearFilters();
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
                        firstName: firstName,
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
                        onSearch: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: _MovieFilterBar(
                        statusFilter: _statusFilter,
                        languageFilter: _languageFilter,
                        languages: languages,
                        onStatusChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                        },
                        onLanguageChanged: (value) {
                          setState(() {
                            _languageFilter = value;
                          });
                        },
                      ),
                    ),
                  ),
                  if (featuredMovies.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverToBoxAdapter(
                        child: _FeaturedMovieCarousel(
                          movies: featuredMovies,
                          theme: theme,
                          colorScheme: colorScheme,
                          onMoviePressed: (movie) =>
                              _openMovieDetails(context, movie),
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
    );
  }

  void _openMovieDetails(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _statusFilter != 'ALL' ||
        _languageFilter != 'ALL';
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    final query = _searchController.text.trim().toLowerCase();
    return movies
        .where((movie) {
          final matchesSearch =
              query.isEmpty || movie.name.toLowerCase().contains(query);
          final matchesStatus =
              _statusFilter == 'ALL' ||
              movie.normalizedReleaseStatus == _statusFilter;
          final matchesLanguage =
              _languageFilter == 'ALL' ||
              movie.language.toLowerCase() == _languageFilter.toLowerCase();
          return matchesSearch && matchesStatus && matchesLanguage;
        })
        .toList(growable: false);
  }

  List<String> _languagesFor(List<Movie> movies) {
    final languages =
        movies
            .map((movie) => movie.language.trim())
            .where((language) => language.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return languages;
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _statusFilter = 'ALL';
      _languageFilter = 'ALL';
    });
    _loadMovies();
  }

  List<Movie> _popularMoviesForCarousel(
    List<Movie> filteredMovies,
    List<Movie> nowShowing,
  ) {
    final source = nowShowing.length >= 5 ? nowShowing : filteredMovies;
    final movies = List<Movie>.of(source);
    final dailySeed = DateTime.now().year * 1000 + DateTime.now().dayOfYear;

    movies.sort((a, b) {
      final scoreCompare = _popularityScore(b).compareTo(_popularityScore(a));
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return _stableDailyRank(
        a,
        dailySeed,
      ).compareTo(_stableDailyRank(b, dailySeed));
    });

    return movies.take(5).toList(growable: false);
  }

  int _popularityScore(Movie movie) {
    var score = 0;
    if (movie.isNowShowing) {
      score += 40;
    }
    if (movie.poster.trim().isNotEmpty) {
      score += 25;
    }
    if (movie.trailerUrl.trim().isNotEmpty) {
      score += 20;
    }
    if (movie.releaseDate != null) {
      final ageInDays = DateTime.now().difference(movie.releaseDate!).inDays;
      if (ageInDays >= 0 && ageInDays <= 90) {
        score += 15;
      }
    }
    return score;
  }

  int _stableDailyRank(Movie movie, int seed) {
    final value = '${movie.id}${movie.name}$seed';
    return value.codeUnits.fold(
      0,
      (sum, code) => (sum * 31 + code) & 0x7fffffff,
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year)).inDays + 1;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.theme,
    required this.colorScheme,
    required this.firstName,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String? firstName;

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
                firstName == null || firstName!.isEmpty
                    ? 'Welcome back'
                    : 'Welcome back, $firstName',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your next show',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFFE2E8F0),
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

class _MovieFilterBar extends StatelessWidget {
  const _MovieFilterBar({
    required this.statusFilter,
    required this.languageFilter,
    required this.languages,
    required this.onStatusChanged,
    required this.onLanguageChanged,
  });

  final String statusFilter;
  final String languageFilter;
  final List<String> languages;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: statusFilter == 'ALL',
          onSelected: (_) => onStatusChanged('ALL'),
        ),
        ChoiceChip(
          label: const Text('Now showing'),
          selected: statusFilter == 'RELEASED',
          onSelected: (_) => onStatusChanged('RELEASED'),
        ),
        ChoiceChip(
          label: const Text('Coming soon'),
          selected: statusFilter == 'UPCOMING',
          onSelected: (_) => onStatusChanged('UPCOMING'),
        ),
        PopupMenuButton<String>(
          tooltip: 'Filter by language',
          onSelected: onLanguageChanged,
          itemBuilder: (context) {
            return [
              const PopupMenuItem(value: 'ALL', child: Text('All languages')),
              for (final language in languages)
                PopupMenuItem(value: language, child: Text(language)),
            ];
          },
          child: Chip(
            avatar: const Icon(Icons.language_rounded, size: 18),
            label: Text(languageFilter == 'ALL' ? 'Language' : languageFilter),
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
      onChanged: onSearch,
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

class _FeaturedMovieCarousel extends StatelessWidget {
  const _FeaturedMovieCarousel({
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
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            padEnds: false,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == movies.length - 1 ? 0 : 14,
                ),
                child: _FeaturedMovieCard(
                  movie: movie,
                  theme: theme,
                  colorScheme: colorScheme,
                  onPressed: () => onMoviePressed(movie),
                ),
              );
            },
          ),
        ),
      ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _PosterImage(movie: movie),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66020617),
                      Color(0x11020617),
                      Color(0xF2020617),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
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
                        Flexible(
                          child: Text(
                            movie.language,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      movie.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MoviePosterFallback extends StatelessWidget {
  const _MoviePosterFallback({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [movie.primaryColor, movie.accentColor],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.white.withValues(alpha: 0.74),
          size: 58,
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.poster.trim();

    if (posterUrl.isEmpty) {
      return _MoviePosterFallback(movie: movie);
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _MoviePosterFallback(movie: movie),
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
          height: 230,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _PosterImage(movie: movie),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22020617),
                      Color(0x22020617),
                      Color(0xEE020617),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: _MovieBadge(label: movie.releaseStatusLabel),
                    ),
                    const Spacer(),
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
                leading: _PosterThumbnail(movie: movie),
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

class _PosterThumbnail extends StatelessWidget {
  const _PosterThumbnail({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: 54, height: 54, child: _PosterImage(movie: movie)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme, this.action});

  final String title;
  final ThemeData theme;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFFE2E8F0),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null) TextButton(onPressed: () {}, child: Text(action!)),
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
