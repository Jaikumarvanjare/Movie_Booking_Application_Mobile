import 'package:flutter/material.dart';

import '../../theatres/presentation/theatre_list_screen.dart';
import '../data/movie.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({required this.movie, super.key});

  final Movie movie;

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
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _DetailsHero(movie: movie, theme: theme),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF2A2118),
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${movie.genre} - ${movie.runtime} - ${movie.language}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF5C4630),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _InfoGrid(movie: movie),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Story', theme: theme),
                      const SizedBox(height: 8),
                      Text(
                        movie.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF5C4630),
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ChipSection(
                        title: 'Cast',
                        values: movie.casts,
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                      _ChipSection(
                        title: 'Available formats',
                        values: movie.formats,
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                      _ChipSection(
                        title: 'Show dates',
                        values: movie.showDates,
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Select showtime', theme: theme),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final time in movie.showTimes)
                            ActionChip(
                              label: Text(time),
                              avatar: const Icon(Icons.schedule_rounded),
                              onPressed: () {},
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TheatreListScreen(movie: movie),
              ),
            );
          },
          icon: const Icon(Icons.event_seat_rounded),
          label: const Text('Book seats'),
        ),
      ),
    );
  }
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({required this.movie, required this.theme});

  final Movie movie;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [movie.primaryColor, movie.accentColor],
        ),
        boxShadow: [
          BoxShadow(
            color: movie.primaryColor.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              _HeroBadge(label: movie.releaseStatus),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.movie_creation_outlined,
            color: Colors.white.withValues(alpha: 0.84),
            size: 64,
          ),
          const SizedBox(height: 18),
          Text(
            movie.badge,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                movie.rating,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _InfoPill(label: 'Director', value: movie.director),
        _InfoPill(label: 'Release', value: movie.releaseDate),
        _InfoPill(label: 'Trailer', value: 'Available'),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2A2118),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.values,
    required this.theme,
  });

  final String title;
  final List<String> values;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, theme: theme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final value in values)
              Chip(
                label: Text(value),
                avatar: const Icon(Icons.local_movies_rounded, size: 18),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: const Color(0xFF2A2118),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
