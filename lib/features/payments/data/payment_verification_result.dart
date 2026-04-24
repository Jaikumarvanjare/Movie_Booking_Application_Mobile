import '../../bookings/data/booking_record.dart';

class PaymentVerificationResult {
  const PaymentVerificationResult({
    required this.booking,
    required this.message,
  });

  final BookingRecord booking;
  final String message;
}
