import '../../bookings/data/booking_draft.dart';

enum PaymentStatus { success, failure }

class PaymentResult {
  const PaymentResult({
    required this.bookingDraft,
    required this.status,
    required this.message,
    this.razorpayOrderId,
    this.razorpayPaymentId,
  });

  final BookingDraft bookingDraft;
  final PaymentStatus status;
  final String message;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;

  bool get isSuccess => status == PaymentStatus.success;
}
