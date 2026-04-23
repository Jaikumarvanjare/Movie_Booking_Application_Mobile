import 'package:flutter/material.dart';

import '../../movies/data/movie.dart';
import '../../seats/presentation/seat_selection_screen.dart';
import '../../theatres/data/theatre.dart';
import '../data/movie_show.dart';

class ShowListScreen extends StatelessWidget {
  const ShowListScreen({required this.movie, required this.theatre, super.key});

  final Movie movie;
  final Theatre theatre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shows = sampleShowsFor(theatreId: theatre.id, movieId: movie.id);

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
                  child: _ShowHeader(
                    movie: movie,
                    theatre: theatre,
                    theme: theme,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: shows.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyShowsCard())
                    : SliverList.separated(
                        itemBuilder: (context, index) {
                          return _ShowCard(
                            movie: movie,
                            theatre: theatre,
                            show: shows[index],
                            theme: theme,
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemCount: shows.length,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShowHeader extends StatelessWidget {
  const _ShowHeader({
    required this.movie,
    required this.theatre,
    required this.theme,
  });

  final Movie movie;
  final Theatre theatre;
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
          'Select show',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${movie.name} at ${theatre.name}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ShowCard extends StatelessWidget {
  const _ShowCard({
    required this.movie,
    required this.theatre,
    required this.show,
    required this.theme,
  });

  final Movie movie;
  final Theatre theatre;
  final MovieShow show;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    show.timeLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Rs ${show.price.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2A2118),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  avatar: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(show.dateLabel),
                ),
                Chip(
                  avatar: const Icon(Icons.event_seat_rounded, size: 18),
                  label: Text('${show.noOfSeats} seats'),
                ),
                Chip(
                  avatar: const Icon(Icons.high_quality_rounded, size: 18),
                  label: Text(show.format),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SeatSelectionScreen(
                        movie: movie,
                        theatre: theatre,
                        show: show,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.event_available_rounded),
                label: const Text('Continue to seats'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShowsCard extends StatelessWidget {
  const _EmptyShowsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No shows found for this theatre yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
