import 'razorpay_order.dart';
import 'payment_verification_result.dart';

abstract class PaymentRepository {
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
