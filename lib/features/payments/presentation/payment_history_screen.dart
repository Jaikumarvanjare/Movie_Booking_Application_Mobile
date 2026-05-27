import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/payment_record.dart';
import '../data/payment_repository.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<PaymentRecord>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = _loadPayments();
  }

  Future<List<PaymentRecord>> _loadPayments() {
    return context.read<PaymentRepository>().fetchPayments();
  }

  Future<void> _refreshPayments() async {
    final future = _loadPayments();
    setState(() {
      _paymentsFuture = future;
    });
    await future;
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
          child: FutureBuilder<List<PaymentRecord>>(
            future: _paymentsFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState != ConnectionState.done;

              if (isLoading && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && !snapshot.hasData) {
                return _PaymentMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load payments',
                  message: snapshot.error.toString(),
                  actionLabel: 'Retry',
                  onPressed: _refreshPayments,
                );
              }

              final payments = snapshot.data ?? const <PaymentRecord>[];

              return RefreshIndicator(
                onRefresh: _refreshPayments,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                  itemCount: payments.length + 1,
                  separatorBuilder: (_, index) => index == 0
                      ? const SizedBox(height: 18)
                      : const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Payment History',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Review successful, pending, and failed payment transactions.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF94A3B8),
                              height: 1.4,
                            ),
                          ),
                          if (payments.isEmpty) ...[
                            const SizedBox(height: 90),
                            const _EmptyPaymentsState(),
                          ],
                        ],
                      );
                    }

                    return _PaymentCard(payment: payments[index - 1]);
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = payment.createdAt == null
        ? 'Date unavailable'
        : DateFormat('d MMM yyyy, h:mm a').format(payment.createdAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusIcon(status: payment.status),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs ${payment.amount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFE2E8F0),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: payment.status),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Booking', value: _shortId(payment.bookingId)),
            const Divider(height: 20),
            _DetailRow(label: 'Payment ID', value: _shortId(payment.id)),
            if (payment.razorpayPaymentId != null) ...[
              const Divider(height: 20),
              _DetailRow(
                label: 'Razorpay payment',
                value: _shortId(payment.razorpayPaymentId!),
              ),
            ],
            if (payment.razorpayOrderId != null) ...[
              const Divider(height: 20),
              _DetailRow(
                label: 'Razorpay order',
                value: _shortId(payment.razorpayOrderId!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status, Theme.of(context).colorScheme);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_statusIcon(status), color: color),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
              color: const Color(0xFFE2E8F0),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPaymentsState extends StatelessWidget {
  const _EmptyPaymentsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
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
              Icons.payments_rounded,
              size: 36,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'No payments yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFE2E8F0),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your payment transactions will appear here after checkout.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _PaymentMessageState extends StatelessWidget {
  const _PaymentMessageState({
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

String _statusLabel(String status) {
  switch (status.trim().toUpperCase()) {
    case 'COMPLETED':
    case 'SUCCESS':
    case 'SUCCESSFULL':
      return 'Paid';
    case 'FAILED':
      return 'Failed';
    case 'PENDING':
      return 'Pending';
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
    case 'FAILED':
      return colorScheme.error;
    case 'PENDING':
      return const Color(0xFFF59E0B);
    case 'PROCESSING':
      return colorScheme.primary;
    default:
      return colorScheme.onSurfaceVariant;
  }
}

IconData _statusIcon(String status) {
  switch (status.trim().toUpperCase()) {
    case 'COMPLETED':
    case 'SUCCESS':
    case 'SUCCESSFULL':
      return Icons.check_circle_rounded;
    case 'FAILED':
      return Icons.error_rounded;
    default:
      return Icons.hourglass_top_rounded;
  }
}

String _shortId(String value) {
  if (value.length <= 8) {
    return value;
  }
  return value.substring(value.length - 8);
}
