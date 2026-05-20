import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../bookings/data/booking_record.dart';
import 'payment_record.dart';
import 'payment_verification_result.dart';
import 'razorpay_order.dart';

class PaymentApiService {
  const PaymentApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PaymentRecord> createPayment({
    required String bookingId,
    required double amount,
    String? razorpayPaymentId,
    String? razorpayOrderId,
  }) async {
    final payload = <String, dynamic>{'bookingId': bookingId, 'amount': amount};
    if (razorpayPaymentId != null) {
      payload['razorpayPaymentId'] = razorpayPaymentId;
    }
    if (razorpayOrderId != null) {
      payload['razorpayOrderId'] = razorpayOrderId;
    }

    final response = await _apiClient.post('/payments', data: payload);

    return PaymentRecord.fromJson(_readPaymentObject(response));
  }

  Future<List<PaymentRecord>> fetchPayments() async {
    final response = await _apiClient.get('/payments');
    return _readPaymentList(
      response,
    ).map(PaymentRecord.fromJson).toList(growable: false);
  }

  Future<PaymentRecord> fetchPaymentById(String id) async {
    final response = await _apiClient.get('/payments/$id');
    return PaymentRecord.fromJson(_readPaymentObject(response));
  }

  Future<RazorpayOrder> createRazorpayOrder({
    required String bookingId,
    required double amount,
  }) async {
    final response = await _apiClient.post(
      '/payments/razorpay/order',
      data: {'bookingId': bookingId, 'amount': amount},
    );

    return RazorpayOrder.fromJson(_readOrderObject(response));
  }

  Future<PaymentVerificationResult> verifyRazorpayPayment({
    required String bookingId,
    required double amount,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _apiClient.post(
      '/payments/razorpay/verify',
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );

    return PaymentVerificationResult(
      booking: BookingRecord.fromJson(_readBookingObject(response)),
      message: response.message.isEmpty
          ? 'Payment verified successfully.'
          : response.message,
    );
  }
}

List<Map<String, dynamic>> _readPaymentList(ApiResponse response) {
  final data = response.data;
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  if (data is Map) {
    final source = Map<String, dynamic>.from(data);
    for (final key in const ['payments', 'items', 'results', 'docs']) {
      final nested = source[key];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
  }
  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> _readPaymentObject(ApiResponse response) {
  final data = response.data;
  if (data is Map<String, dynamic>) {
    for (final key in const ['payment', 'item']) {
      final nested = data[key];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  throw const ApiException(
    message: 'The payment response did not include payment details.',
  );
}

Map<String, dynamic> _readOrderObject(ApiResponse response) {
  final data = response.data;
  if (data is Map<String, dynamic>) {
    for (final key in const ['order', 'paymentOrder', 'item']) {
      final nested = data[key];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  throw const ApiException(
    message: 'The payment order response did not include order details.',
  );
}

Map<String, dynamic> _readBookingObject(ApiResponse response) {
  final data = response.data;
  if (data is Map<String, dynamic>) {
    for (final key in const ['booking', 'item']) {
      final nested = data[key];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  throw const ApiException(
    message:
        'The payment verification response did not include booking details.',
  );
}
