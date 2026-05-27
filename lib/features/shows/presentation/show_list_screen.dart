import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../movies/data/movie.dart';
import '../../seats/presentation/seat_selection_screen.dart';
import '../../theatres/data/theatre.dart';
import '../data/movie_show.dart';
import '../data/show_repository.dart';

class ShowListScreen extends StatefulWidget {
  const ShowListScreen({required this.movie, required this.theatre, super.key});

  final Movie movie;
  final Theatre theatre;

  @override
  State<ShowListScreen> createState() => _ShowListScreenState();
}

class _ShowListScreenState extends State<ShowListScreen> {
  late Future<List<MovieShow>> _showsFuture;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _showsFuture = context.read<ShowRepository>().fetchShows(
      theatreId: widget.theatre.id,
      movieId: widget.movie.id,
    );
  }

  void _reload() {
    setState(() {
      _showsFuture = context.read<ShowRepository>().fetchShows(
        theatreId: widget.theatre.id,
        movieId: widget.movie.id,
      );
    });
  }

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
          child: FutureBuilder<List<MovieShow>>(
            future: _showsFuture,
            builder: (context, snapshot) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: _ShowHeader(
                        movie: widget.movie,
                        theatre: widget.theatre,
                        theme: theme,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    sliver: SliverToBoxAdapter(
                      child: _buildBody(snapshot, theme),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<List<MovieShow>> snapshot, ThemeData theme) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return _InfoCard(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load shows',
        message: '${snapshot.error}',
        actionLabel: 'Retry',
        onPressed: _reload,
      );
    }

    final shows = snapshot.data ?? const <MovieShow>[];
    final dates = _uniqueShowDates(shows);
    final filteredShows = _selectedDate == null
        ? shows
        : shows
              .where((show) => _isSameDay(show.timing, _selectedDate!))
              .toList(growable: false);

    if (shows.isEmpty) {
      return _InfoCard(
        icon: Icons.schedule_rounded,
        title: 'No shows found',
        message: 'The backend has not returned shows for this theatre yet.',
        actionLabel: 'Retry',
        onPressed: _reload,
      );
    }

    if (filteredShows.isEmpty) {
      return Column(
        children: [
          _ShowDateFilter(
            dates: dates,
            selectedDate: _selectedDate,
            onSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 14),
          _InfoCard(
            icon: Icons.event_busy_rounded,
            title: 'No shows on this date',
            message: 'Choose another date to view available showtimes.',
            actionLabel: 'Show all dates',
            onPressed: () {
              setState(() {
                _selectedDate = null;
              });
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        _ShowDateFilter(
          dates: dates,
          selectedDate: _selectedDate,
          onSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        const SizedBox(height: 14),
        for (final show in filteredShows) ...[
          _ShowCard(
            movie: widget.movie,
            theatre: widget.theatre,
            show: show,
            theme: theme,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ShowDateFilter extends StatelessWidget {
  const _ShowDateFilter({
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All dates'),
            selected: selectedDate == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final date in dates)
            ChoiceChip(
              label: Text(_dateChipLabel(date)),
              selected: selectedDate != null && _isSameDay(selectedDate!, date),
              onSelected: (_) => onSelected(date),
            ),
        ],
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
            color: const Color(0xFFE2E8F0),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${movie.name} at ${theatre.name}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF94A3B8),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

List<DateTime> _uniqueShowDates(List<MovieShow> shows) {
  final dates = <DateTime>[];
  for (final show in shows) {
    final date = DateTime(show.timing.year, show.timing.month, show.timing.day);
    if (!dates.any((existing) => _isSameDay(existing, date))) {
      dates.add(date);
    }
  }
  dates.sort();
  return dates;
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _dateChipLabel(DateTime date) {
  final now = DateTime.now();
  if (_isSameDay(date, now)) {
    return 'Today';
  }
  return '${date.day}/${date.month}';
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
                    color: const Color(0xFFE2E8F0),
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
                  label: Text(show.formatLabel),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
