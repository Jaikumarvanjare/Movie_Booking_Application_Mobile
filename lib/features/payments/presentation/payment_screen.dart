import 'package:flutter/material.dart';

import '../../bookings/data/booking_draft.dart';
import '../data/payment_result.dart';
import 'payment_result_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({required this.bookingDraft, super.key});

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
                sliver: SliverToBoxAdapter(child: _PaymentHeader(theme: theme)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RazorpayCard(bookingDraft: bookingDraft, theme: theme),
                      const SizedBox(height: 18),
                      _PaymentRecap(bookingDraft: bookingDraft),
                      const SizedBox(height: 18),
                      _IntegrationNote(theme: theme),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Amount due', style: theme.textTheme.bodySmall),
                Text(
                  'Rs ${bookingDraft.totalCost.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2A2118),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _openMockRazorpay(context),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text('Pay with Razorpay'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _openMockFailure(context),
                  child: const Text('Simulate payment failure'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMockRazorpay(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PaymentResultScreen(
          paymentResult: PaymentResult(
            bookingDraft: bookingDraft,
            status: PaymentStatus.success,
            message:
                'Your Razorpay payment was simulated successfully. Real verification will be connected with the backend later.',
            razorpayOrderId: 'order_mock_${bookingDraft.show.id}',
            razorpayPaymentId: 'pay_mock_${bookingDraft.show.id}',
          ),
        ),
      ),
    );
  }

  void _openMockFailure(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PaymentResultScreen(
          paymentResult: PaymentResult(
            bookingDraft: bookingDraft,
            status: PaymentStatus.failure,
            message:
                'The simulated Razorpay payment failed. You can retry from the booking flow.',
            razorpayOrderId: 'order_mock_${bookingDraft.show.id}',
          ),
        ),
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.theme});

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
          'Payment',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete your booking with the Razorpay payment flow.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RazorpayCard extends StatelessWidget {
  const _RazorpayCard({required this.bookingDraft, required this.theme});

  final BookingDraft bookingDraft;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3D91), Color(0xFF2D9CDB)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 46,
          ),
          const SizedBox(height: 34),
          Text(
            'Razorpay checkout',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mock order for ${bookingDraft.movie.name}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRecap extends StatelessWidget {
  const _PaymentRecap({required this.bookingDraft});

  final BookingDraft bookingDraft;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _PaymentRow(label: 'Movie', value: bookingDraft.movie.name),
            const Divider(height: 20),
            _PaymentRow(label: 'Theatre', value: bookingDraft.theatre.name),
            const Divider(height: 20),
            _PaymentRow(label: 'Seats', value: bookingDraft.seatLabels),
            const Divider(height: 20),
            _PaymentRow(
              label: 'Amount',
              value: 'Rs ${bookingDraft.totalCost.toStringAsFixed(0)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
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

class _IntegrationNote extends StatelessWidget {
  const _IntegrationNote({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Next integration step: create booking, call Razorpay order API, open Razorpay SDK, then verify payment with the backend.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
