import 'package:flutter/material.dart';

import '../../movies/data/movie.dart';
import '../../shows/presentation/show_list_screen.dart';
import '../data/theatre.dart';

class TheatreListScreen extends StatelessWidget {
  const TheatreListScreen({required this.movie, super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final theatres = sampleTheatresForMovie(movie.id);

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
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _TheatreHeader(movie: movie, theme: theme),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(child: _FilterRow(movie: movie)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final theatre = theatres[index];
                    return _TheatreCard(
                      theatre: theatre,
                      theme: theme,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ShowListScreen(movie: movie, theatre: theatre),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemCount: theatres.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TheatreHeader extends StatelessWidget {
  const _TheatreHeader({required this.movie, required this.theme});

  final Movie movie;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 28),
        Text(
          'Choose theatre',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Available theatres for ${movie.name}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Chip(
          avatar: const Icon(Icons.location_city_rounded, size: 18),
          label: const Text('Pune'),
        ),
        Chip(
          avatar: const Icon(Icons.local_movies_rounded, size: 18),
          label: Text(movie.badge),
        ),
        const Chip(
          avatar: Icon(Icons.near_me_rounded, size: 18),
          label: Text('Nearby first'),
        ),
      ],
    );
  }
}

class _TheatreCard extends StatelessWidget {
  const _TheatreCard({
    required this.theatre,
    required this.theme,
    required this.onPressed,
  });

  final Theatre theatre;
  final ThemeData theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.theaters_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theatre.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF2A2118),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${theatre.city} - ${theatre.distance}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                theatre.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5C4630),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${theatre.address} - ${theatre.pincode}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final format in theatre.formats)
                    Chip(label: Text(format)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
