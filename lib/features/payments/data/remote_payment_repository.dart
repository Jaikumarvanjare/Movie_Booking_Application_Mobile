import 'payment_api_service.dart';
import 'payment_record.dart';
import 'payment_repository.dart';
import 'payment_verification_result.dart';
import 'razorpay_order.dart';

class RemotePaymentRepository implements PaymentRepository {
  const RemotePaymentRepository({required PaymentApiService paymentApiService})
    : _paymentApiService = paymentApiService;

  final PaymentApiService _paymentApiService;

  @override
  Future<PaymentRecord> createPayment({
    required String bookingId,
    required double amount,
    String? razorpayPaymentId,
    String? razorpayOrderId,
  }) {
    return _paymentApiService.createPayment(
      bookingId: bookingId,
      amount: amount,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
    );
  }

  @override
  Future<List<PaymentRecord>> fetchPayments() {
    return _paymentApiService.fetchPayments();
  }

  @override
  Future<PaymentRecord> fetchPaymentById(String id) {
    return _paymentApiService.fetchPaymentById(id);
  }

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
