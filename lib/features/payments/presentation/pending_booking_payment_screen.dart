import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/session_controller.dart';
import '../../bookings/data/booking_record.dart';
import '../data/payment_gateway.dart';
import '../data/payment_repository.dart';
import '../data/razorpay_order.dart';

class PendingBookingPaymentScreen extends StatefulWidget {
  const PendingBookingPaymentScreen({required this.booking, super.key});

  final BookingRecord booking;

  @override
  State<PendingBookingPaymentScreen> createState() =>
      _PendingBookingPaymentScreenState();
}

class _PendingBookingPaymentScreenState
    extends State<PendingBookingPaymentScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;
  RazorpayOrder? _order;

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 120),
            children: [
              IconButton.filledTonal(
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 28),
              Text(
                'Complete payment',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF2A2118),
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pay the pending amount for this booking to confirm your ticket.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5C4630),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),
              _PendingPaymentCard(booking: widget.booking, order: _order),
              if (_errorMessage != null) ...[
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: FilledButton.icon(
          onPressed: _isSubmitting ? null : _startPayment,
          icon: const Icon(Icons.payment_rounded),
          label: Text(
            _isSubmitting
                ? 'Opening checkout...'
                : 'Pay Rs ${widget.booking.totalCost.toStringAsFixed(0)}',
          ),
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final paymentRepository = context.read<PaymentRepository>();
      final paymentGateway = context.read<PaymentGateway>();
      final sessionController = context.read<SessionController>();

      final order = await paymentRepository.createRazorpayOrder(
        bookingId: widget.booking.id,
        amount: widget.booking.totalCost,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _order = order;
      });

      final config = AppConfig.fromEnvironment();
      final razorpayKeyId = order.keyId ?? config.razorpayKeyId;
      if (razorpayKeyId.trim().isEmpty) {
        throw ApiException.configuration(
          'RAZORPAY_KEY_ID is missing. Add it to .env before starting checkout.',
        );
      }

      final checkoutResult = await paymentGateway.openCheckout(
        PaymentGatewayRequest(
          orderId: order.orderId,
          amount: order.amount,
          currency: order.currency,
          keyId: razorpayKeyId,
          userName: sessionController.user?.name ?? 'CineBook User',
          userEmail: sessionController.user?.email ?? '',
          description: 'Booking ${_shortId(widget.booking.id)}',
        ),
      );

      await paymentRepository.verifyRazorpayPayment(
        bookingId: widget.booking.id,
        amount: widget.booking.totalCost,
        razorpayOrderId: checkoutResult.razorpayOrderId,
        razorpayPaymentId: checkoutResult.razorpayPaymentId,
        razorpaySignature: checkoutResult.razorpaySignature,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful. Booking confirmed.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _messageForPaymentError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _PendingPaymentCard extends StatelessWidget {
  const _PendingPaymentCard({required this.booking, required this.order});

  final BookingRecord booking;
  final RazorpayOrder? order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _DetailRow(label: 'Booking ID', value: _shortId(booking.id)),
            const Divider(height: 20),
            _DetailRow(label: 'Status', value: _labelize(booking.status)),
            const Divider(height: 20),
            _DetailRow(label: 'Seats', value: '${booking.noOfSeats ?? 0}'),
            const Divider(height: 20),
            _DetailRow(
              label: 'Amount',
              value: 'Rs ${booking.totalCost.toStringAsFixed(0)}',
            ),
            if (order != null) ...[
              const Divider(height: 20),
              _DetailRow(label: 'Order ID', value: _shortId(order!.orderId)),
            ],
          ],
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
              color: const Color(0xFF2A2118),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

String _messageForPaymentError(Object error) {
  if (error is ApiException || error is PaymentGatewayException) {
    return error.toString();
  }
  return 'Could not complete payment. Please try again.';
}

String _shortId(String value) {
  if (value.length <= 8) {
    return value;
  }
  return value.substring(value.length - 8);
}

String _labelize(String value) {
  return value
      .trim()
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) {
        final lowercase = part.toLowerCase();
        return '${lowercase[0].toUpperCase()}${lowercase.substring(1)}';
      })
      .join(' ');
}
