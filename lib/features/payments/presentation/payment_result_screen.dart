import 'package:flutter/material.dart';

import '../../../app/app_home.dart';
import '../data/payment_result.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({required this.paymentResult, super.key});

  final PaymentResult paymentResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = paymentResult.isSuccess
        ? 'Payment successful'
        : 'Payment failed';
    final icon = paymentResult.isSuccess
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    final iconColor = paymentResult.isSuccess
        ? const Color(0xFF2F8F46)
        : colorScheme.error;

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(icon, color: iconColor, size: 84),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  paymentResult.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF94A3B8),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResultRow(
                          label: 'Movie',
                          value: paymentResult.bookingDraft.movie.name,
                        ),
                        const Divider(height: 20),
                        _ResultRow(
                          label: 'Theatre',
                          value: paymentResult.bookingDraft.theatre.name,
                        ),
                        const Divider(height: 20),
                        _ResultRow(
                          label: 'Seats',
                          value: paymentResult.bookingDraft.seatLabels,
                        ),
                        const Divider(height: 20),
                        _ResultRow(
                          label: 'Amount',
                          value:
                              'Rs ${paymentResult.bookingDraft.totalCost.toStringAsFixed(0)}',
                        ),
                        if (paymentResult.razorpayPaymentId != null) ...[
                          const Divider(height: 20),
                          _ResultRow(
                            label: 'Payment ID',
                            value: paymentResult.razorpayPaymentId!,
                          ),
                        ],
                        if (paymentResult.razorpayOrderId != null) ...[
                          const Divider(height: 20),
                          _ResultRow(
                            label: 'Order ID',
                            value: paymentResult.razorpayOrderId!,
                          ),
                        ],
                        if (paymentResult.booking != null) ...[
                          const Divider(height: 20),
                          _ResultRow(
                            label: 'Booking ID',
                            value: paymentResult.booking!.id,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const CustomerShell(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

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
