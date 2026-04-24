import 'package:flutter/material.dart';

import '../../bookings/data/booking_draft.dart';
import '../../bookings/presentation/booking_summary_screen.dart';
import '../../movies/data/movie.dart';
import '../../shows/data/movie_show.dart';
import '../../theatres/data/theatre.dart';
import '../data/seat.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({
    required this.movie,
    required this.theatre,
    required this.show,
    super.key,
  });

  final Movie movie;
  final Theatre theatre;
  final MovieShow show;

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Set<String> _selectedSeatIds = {};

  late final List<Seat> _seats = seatsForShow(widget.show);

  double get _totalCost => _selectedSeatIds.length * widget.show.price;

  List<Seat> get _selectedSeats {
    return _seats
        .where((seat) => _selectedSeatIds.contains(seat.id))
        .toList(growable: false);
  }

  void _toggleSeat(Seat seat) {
    if (seat.isBooked) {
      return;
    }

    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else {
        _selectedSeatIds.add(seat.id);
      }
    });
  }

  void _continueToReview() {
    if (_selectedSeatIds.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSummaryScreen(
          bookingDraft: BookingDraft(
            movie: widget.movie,
            theatre: widget.theatre,
            show: widget.show,
            selectedSeats: _selectedSeats,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedSeatsLabel = _selectedSeats.isEmpty
        ? 'No seats selected'
        : _selectedSeats.map((seat) => seat.label).join(', ');
    final hasSeatLayout = _seats.isNotEmpty;

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
                  child: _SeatHeader(
                    movie: widget.movie,
                    theatre: widget.theatre,
                    show: widget.show,
                    theme: theme,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _ScreenIndicator(colorScheme: colorScheme),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(child: _SeatLegend(theme: theme)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverToBoxAdapter(
                  child: hasSeatLayout
                      ? _SeatGrid(
                          seats: _seats,
                          selectedSeatIds: _selectedSeatIds,
                          onSeatPressed: _toggleSeat,
                        )
                      : const _SeatLayoutUnavailableCard(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_selectedSeatIds.length} seats selected',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedSeatsLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Total Rs ${_totalCost.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF2A2118),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: !hasSeatLayout || _selectedSeatIds.isEmpty
                          ? null
                          : _continueToReview,
                      child: const Text('Review booking'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatHeader extends StatelessWidget {
  const _SeatHeader({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 28),
        Text(
          'Select seats',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${movie.name} at ${theatre.name} - ${show.timeLabel}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
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
              avatar: const Icon(Icons.high_quality_rounded, size: 18),
              label: Text(show.formatLabel),
            ),
            Chip(
              avatar: const Icon(Icons.currency_rupee_rounded, size: 18),
              label: Text('Rs ${show.price.toStringAsFixed(0)} each'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScreenIndicator extends StatelessWidget {
  const _ScreenIndicator({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2118),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        'SCREEN',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _LegendItem(label: 'Available', color: Colors.white, theme: theme),
        _LegendItem(
          label: 'Selected',
          color: Theme.of(context).colorScheme.primary,
          theme: theme,
        ),
        _LegendItem(
          label: 'Booked',
          color: Theme.of(context).colorScheme.outlineVariant,
          theme: theme,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
    required this.theme,
  });

  final String label;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _SeatGrid extends StatelessWidget {
  const _SeatGrid({
    required this.seats,
    required this.selectedSeatIds,
    required this.onSeatPressed,
  });

  final List<Seat> seats;
  final Set<String> selectedSeatIds;
  final ValueChanged<Seat> onSeatPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final seat in seats)
          _SeatTile(
            seat: seat,
            isSelected: selectedSeatIds.contains(seat.id),
            onPressed: () => onSeatPressed(seat),
          ),
      ],
    );
  }
}

class _SeatLayoutUnavailableCard extends StatelessWidget {
  const _SeatLayoutUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Seat layout is not available from the backend for this show yet.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
      ),
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.seat,
    required this.isSelected,
    required this.onPressed,
  });

  final Seat seat;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = seat.isBooked
        ? colorScheme.outlineVariant
        : isSelected
        ? colorScheme.primary
        : Colors.white;
    final foregroundColor = isSelected ? Colors.white : const Color(0xFF2A2118);

    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: seat.isBooked ? null : onPressed,
          child: Center(
            child: Text(
              seat.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
