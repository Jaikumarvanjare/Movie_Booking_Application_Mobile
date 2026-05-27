import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/session_controller.dart';
import '../../bookings/data/booking_draft.dart';
import '../../bookings/data/booking_record.dart';
import '../../bookings/data/booking_repository.dart';
import '../data/payment_gateway.dart';
import '../data/payment_repository.dart';
import '../data/payment_result.dart';
import '../data/razorpay_order.dart';
import 'payment_result_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({required this.bookingDraft, super.key});

  final BookingDraft bookingDraft;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;
  String _statusMessage = 'Ready to create the booking and open checkout.';
  BookingRecord? _createdBooking;
  RazorpayOrder? _createdOrder;

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
                      _RazorpayCard(
                        bookingDraft: widget.bookingDraft,
                        theme: theme,
                        order: _createdOrder,
                        statusMessage: _statusMessage,
                      ),
                      const SizedBox(height: 18),
                      _PaymentRecap(bookingDraft: widget.bookingDraft),
                      if (_createdBooking != null) ...[
                        const SizedBox(height: 18),
                        _BackendInfoCard(
                          title: 'Booking status',
                          lines: [
                            'Booking ID: ${_createdBooking!.id}',
                            'Status: ${_createdBooking!.status}',
                          ],
                        ),
                      ],
                      if (_createdOrder != null) ...[
                        const SizedBox(height: 18),
                        _BackendInfoCard(
                          title: 'Razorpay order',
                          lines: [
                            'Order ID: ${_createdOrder!.orderId}',
                            'Amount: ${_createdOrder!.amount.toStringAsFixed(0)} ${_createdOrder!.currency}',
                          ],
                        ),
                      ],
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 18),
                        _BackendInfoCard(
                          title: 'Payment error',
                          lines: [_errorMessage!],
                          isError: true,
                        ),
                      ],
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
                  'Rs ${widget.bookingDraft.totalCost.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _startPayment,
                  icon: const Icon(Icons.payment_rounded),
                  label: Text(
                    _isSubmitting ? 'Opening checkout...' : 'Pay with Razorpay',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _statusMessage = 'Creating booking...';
    });

    try {
      final bookingRepository = context.read<BookingRepository>();
      final paymentRepository = context.read<PaymentRepository>();
      final paymentGateway = context.read<PaymentGateway>();
      final sessionController = context.read<SessionController>();

      final booking = await bookingRepository.createBooking(
        widget.bookingDraft,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _createdBooking = booking;
        _statusMessage = 'Booking created. Requesting Razorpay order...';
      });

      final order = await paymentRepository.createRazorpayOrder(
        bookingId: booking.id,
        amount: widget.bookingDraft.totalCost,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _createdOrder = order;
        _statusMessage = 'Razorpay order ready. Opening checkout...';
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
          description:
              '${widget.bookingDraft.movie.name} at ${widget.bookingDraft.theatre.name}',
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Payment received. Verifying with backend...';
      });

      final verificationResult = await paymentRepository.verifyRazorpayPayment(
        bookingId: booking.id,
        amount: widget.bookingDraft.totalCost,
        razorpayOrderId: checkoutResult.razorpayOrderId,
        razorpayPaymentId: checkoutResult.razorpayPaymentId,
        razorpaySignature: checkoutResult.razorpaySignature,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
            builder: (_) => PaymentResultScreen(
              paymentResult: PaymentResult(
                bookingDraft: widget.bookingDraft,
                booking: verificationResult.booking,
                status: PaymentStatus.success,
                message: verificationResult.message,
                razorpayOrderId: checkoutResult.razorpayOrderId,
                razorpayPaymentId: checkoutResult.razorpayPaymentId,
              ),
            ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _buildPaymentErrorMessage(error);

      setState(() {
        _errorMessage = message;
        _statusMessage = 'Payment flow stopped.';
      });

      if (_createdBooking != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => PaymentResultScreen(
              paymentResult: PaymentResult(
                bookingDraft: widget.bookingDraft,
                booking: _createdBooking,
                status: PaymentStatus.failure,
                message: message,
                razorpayOrderId: _createdOrder?.orderId,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _buildPaymentErrorMessage(Object error) {
    final detail = error is ApiException || error is PaymentGatewayException
        ? error.toString()
        : 'Could not complete the payment flow. Please try again.';

    if (_createdBooking == null) {
      return 'Booking creation failed. $detail';
    }
    if (_createdOrder == null) {
      return 'Razorpay order request failed. $detail';
    }
    if (error is PaymentGatewayException) {
      return 'Razorpay checkout failed. $detail';
    }
    return 'Payment verification failed. $detail';
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
            color: const Color(0xFFE2E8F0),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create the booking, request a Razorpay order, and complete checkout.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF94A3B8),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RazorpayCard extends StatelessWidget {
  const _RazorpayCard({
    required this.bookingDraft,
    required this.theme,
    required this.order,
    required this.statusMessage,
  });

  final BookingDraft bookingDraft;
  final ThemeData theme;
  final RazorpayOrder? order;
  final String statusMessage;

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
            order == null
                ? 'A live booking and Razorpay order will be created for ${bookingDraft.movie.name}.'
                : 'Live order ${order!.orderId} is ready for ${bookingDraft.movie.name}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            statusMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
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
              color: const Color(0xFFE2E8F0),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackendInfoCard extends StatelessWidget {
  const _BackendInfoCard({
    required this.title,
    required this.lines,
    this.isError = false,
  });

  final String title;
  final List<String> lines;
  final bool isError;

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
                color: isError
                    ? theme.colorScheme.error
                    : const Color(0xFFE2E8F0),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final line in lines) ...[
              Text(
                line,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (line != lines.last) const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
