import 'razorpay_order.dart';
import 'payment_record.dart';
import 'payment_verification_result.dart';

abstract class PaymentRepository {
  Future<PaymentRecord> createPayment({
    required String bookingId,
    required double amount,
    String? razorpayPaymentId,
    String? razorpayOrderId,
  });

  Future<List<PaymentRecord>> fetchPayments();

  Future<PaymentRecord> fetchPaymentById(String id);

  Future<RazorpayOrder> createRazorpayOrder({
    required String bookingId,
    required double amount,
  });

  Future<PaymentVerificationResult> verifyRazorpayPayment({
    required String bookingId,
    required double amount,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
}
