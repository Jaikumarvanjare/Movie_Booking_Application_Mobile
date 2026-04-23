import 'package:flutter/material.dart';

import '../../payments/presentation/payment_screen.dart';
import '../data/booking_draft.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({required this.bookingDraft, super.key});

  final BookingDraft bookingDraft;

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
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                sliver: SliverToBoxAdapter(child: _SummaryHeader(theme: theme)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BookingHero(bookingDraft: bookingDraft, theme: theme),
                      const SizedBox(height: 22),
                      _SummaryCard(
                        title: 'Movie',
                        rows: [
                          _SummaryRow('Name', bookingDraft.movie.name),
                          _SummaryRow('Language', bookingDraft.movie.language),
                          _SummaryRow('Format', bookingDraft.show.format),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SummaryCard(
                        title: 'Theatre',
                        rows: [
                          _SummaryRow('Name', bookingDraft.theatre.name),
                          _SummaryRow('City', bookingDraft.theatre.city),
                          _SummaryRow('Address', bookingDraft.theatre.address),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SummaryCard(
                        title: 'Show',
                        rows: [
                          _SummaryRow('Date', bookingDraft.show.dateLabel),
                          _SummaryRow('Time', bookingDraft.show.timeLabel),
                          _SummaryRow(
                            'Ticket price',
                            'Rs ${bookingDraft.show.price.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SummaryCard(
                        title: 'Seats',
                        rows: [
                          _SummaryRow(
                            'Selected seats',
                            bookingDraft.seatLabels,
                          ),
                          _SummaryRow(
                            'No. of seats',
                            bookingDraft.noOfSeats.toString(),
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total amount', style: theme.textTheme.bodySmall),
                      Text(
                        'Rs ${bookingDraft.totalCost.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2A2118),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PaymentScreen(bookingDraft: bookingDraft),
                      ),
                    );
                  },
                  child: const Text('Proceed to payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.theme});

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
          'Booking summary',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your movie, theatre, show, and seats before payment.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _BookingHero extends StatelessWidget {
  const _BookingHero({required this.bookingDraft, required this.theme});

  final BookingDraft bookingDraft;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bookingDraft.movie.primaryColor,
            bookingDraft.movie.accentColor,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 44,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 28),
          Text(
            bookingDraft.movie.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${bookingDraft.theatre.name} - ${bookingDraft.show.timeLabel}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.rows});

  final String title;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2A2118),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final row in rows) ...[
              _SummaryRowTile(row: row),
              if (row != rows.last) const Divider(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRowTile extends StatelessWidget {
  const _SummaryRowTile({required this.row});

  final _SummaryRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            row.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            row.value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2A2118),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;
}
