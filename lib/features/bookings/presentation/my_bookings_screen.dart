import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/booking_record.dart';
import '../data/booking_repository.dart';
import '../../payments/presentation/pending_booking_payment_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({required this.onBrowseMovies, super.key});

  final VoidCallback onBrowseMovies;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<BookingRecord>> _bookingsFuture;
  String? _busyBookingId;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _loadBookings();
  }

  Future<List<BookingRecord>> _loadBookings() {
    return context.read<BookingRepository>().fetchBookings();
  }

  Future<void> _refreshBookings() async {
    final future = _loadBookings();
    setState(() {
      _bookingsFuture = future;
    });
    await future;
  }

  Future<void> _confirmCancel(BookingRecord booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel booking?'),
          content: const Text(
            'This will cancel the selected booking. You can book again if seats are still available.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep booking'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancel booking'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      await _cancelBooking(booking);
    }
  }

  Future<void> _cancelBooking(BookingRecord booking) async {
    setState(() {
      _busyBookingId = booking.id;
    });

    try {
      await context.read<BookingRepository>().cancelBooking(booking.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully.')),
      );
      await _refreshBookings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _busyBookingId = null;
        });
      }
    }
  }

  Future<void> _payNow(BookingRecord booking) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PendingBookingPaymentScreen(booking: booking),
      ),
    );

    if (paid == true && mounted) {
      await _refreshBookings();
    }
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
            colors: [Color(0xFFFFE0B8), Color(0xFFFFF4E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<BookingRecord>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState != ConnectionState.done;

              if (isLoading && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && !snapshot.hasData) {
                return _BookingsMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load bookings',
                  message: snapshot.error.toString(),
                  actionLabel: 'Retry',
                  onPressed: _refreshBookings,
                );
              }

              final bookings = snapshot.data ?? const <BookingRecord>[];

              if (bookings.isEmpty) {
                return _EmptyBookingsState(
                  onBrowseMovies: widget.onBrowseMovies,
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshBookings,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  itemCount: bookings.length + 1,
                  separatorBuilder: (_, index) => index == 0
                      ? const SizedBox(height: 18)
                      : const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Bookings',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF2A2118),
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track tickets, pending payments, and cancellations.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF5C4630),
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    }

                    final booking = bookings[index - 1];
                    return _BookingCard(
                      booking: booking,
                      isBusy: _busyBookingId == booking.id,
                      onCancel: _canManagePayment(booking.status)
                          ? () => _confirmCancel(booking)
                          : null,
                      onPayNow: _canManagePayment(booking.status)
                          ? () => _payNow(booking)
                          : null,
                    );
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isBusy,
    required this.onCancel,
    required this.onPayNow,
  });

  final BookingRecord booking;
  final bool isBusy;
  final VoidCallback? onCancel;
  final VoidCallback? onPayNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timing = booking.timing == null
        ? 'Show time unavailable'
        : DateFormat('EEE, d MMM yyyy, h:mm a').format(booking.timing!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusBadge(status: booking.status),
                      _IdBadge(id: booking.id),
                    ],
                  ),
                ),
                Text(
                  'Rs ${booking.totalCost.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2A2118),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              timing,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF2A2118),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.event_seat_outlined,
                  label: '${booking.noOfSeats ?? 0} seats',
                ),
                if (booking.seat != null && booking.seat!.trim().isNotEmpty)
                  _MetaChip(icon: Icons.chair_outlined, label: booking.seat!),
                if (booking.movieId != null)
                  _MetaChip(
                    icon: Icons.local_movies_outlined,
                    label: _shortId(booking.movieId!),
                  ),
                if (booking.theatreId != null)
                  _MetaChip(
                    icon: Icons.apartment_outlined,
                    label: _shortId(booking.theatreId!),
                  ),
              ],
            ),
            if (onPayNow != null || onCancel != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onPayNow != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isBusy ? null : onPayNow,
                        icon: const Icon(Icons.payment_rounded),
                        label: const Text('Pay now'),
                      ),
                    ),
                  if (onPayNow != null && onCancel != null)
                    const SizedBox(width: 10),
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isBusy ? null : onCancel,
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(isBusy ? 'Cancelling...' : 'Cancel'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status, Theme.of(context).colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _IdBadge extends StatelessWidget {
  const _IdBadge({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        'ID ${_shortId(id)}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF5C4630),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBookingsState extends StatelessWidget {
  const _EmptyBookingsState({required this.onBrowseMovies});

  final VoidCallback onBrowseMovies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(
                Icons.confirmation_number_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No bookings yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2A2118),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your tickets and pending payments will appear here after you reserve seats for a show.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onBrowseMovies,
              icon: const Icon(Icons.local_movies_rounded),
              label: const Text('Browse movies'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsMessageState extends StatelessWidget {
  const _BookingsMessageState({
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
  final Future<void> Function() onPressed;

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

bool _canManagePayment(String status) {
  final normalized = status.trim().toUpperCase();
  return normalized == 'PENDING' || normalized == 'PROCESSING';
}

String _statusLabel(String status) {
  switch (status.trim().toUpperCase()) {
    case 'COMPLETED':
    case 'SUCCESS':
    case 'SUCCESSFULL':
      return 'Confirmed';
    case 'CANCELLED':
      return 'Cancelled';
    case 'PENDING':
      return 'Pending payment';
    case 'PROCESSING':
      return 'Processing';
    default:
      return status
          .trim()
          .split('_')
          .where((part) => part.isNotEmpty)
          .map((part) {
            final lowercase = part.toLowerCase();
            return '${lowercase[0].toUpperCase()}${lowercase.substring(1)}';
          })
          .join(' ');
  }
}

Color _statusColor(String status, ColorScheme colorScheme) {
  switch (status.trim().toUpperCase()) {
    case 'COMPLETED':
    case 'SUCCESS':
    case 'SUCCESSFULL':
      return const Color(0xFF2F8F46);
    case 'CANCELLED':
      return colorScheme.error;
    case 'PENDING':
      return const Color(0xFF8A5C00);
    case 'PROCESSING':
      return colorScheme.primary;
    default:
      return colorScheme.onSurfaceVariant;
  }
}

String _shortId(String value) {
  if (value.length <= 8) {
    return value;
  }
  return value.substring(value.length - 8);
}
