import '../../bookings/data/booking_draft.dart';
import '../../bookings/data/booking_record.dart';

enum PaymentStatus { success, failure }

class PaymentResult {
  const PaymentResult({
    required this.bookingDraft,
    required this.status,
    required this.message,
    this.booking,
    this.razorpayOrderId,
    this.razorpayPaymentId,
  });

  final BookingDraft bookingDraft;
  final PaymentStatus status;
  final String message;
  final BookingRecord? booking;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;

  bool get isSuccess => status == PaymentStatus.success;
}
