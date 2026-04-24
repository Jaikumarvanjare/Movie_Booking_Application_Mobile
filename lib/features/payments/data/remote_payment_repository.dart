import 'payment_api_service.dart';
import 'payment_repository.dart';
import 'payment_verification_result.dart';
import 'razorpay_order.dart';

class RemotePaymentRepository implements PaymentRepository {
  const RemotePaymentRepository({required PaymentApiService paymentApiService})
    : _paymentApiService = paymentApiService;

  final PaymentApiService _paymentApiService;

  @override
  Future<RazorpayOrder> createRazorpayOrder({
    required String bookingId,
    required double amount,
  }) {
    return _paymentApiService.createRazorpayOrder(
      bookingId: bookingId,
      amount: amount,
    );
  }

  @override
  Future<PaymentVerificationResult> verifyRazorpayPayment({
    required String bookingId,
    required double amount,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return _paymentApiService.verifyRazorpayPayment(
      bookingId: bookingId,
      amount: amount,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }
}
