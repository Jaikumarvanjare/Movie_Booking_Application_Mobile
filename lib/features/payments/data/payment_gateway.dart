class PaymentGatewayRequest {
  const PaymentGatewayRequest({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.userName,
    required this.userEmail,
    required this.description,
  });

  final String orderId;
  final double amount;
  final String currency;
  final String keyId;
  final String userName;
  final String userEmail;
  final String description;
}

class PaymentGatewaySuccess {
  const PaymentGatewaySuccess({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
}

class PaymentGatewayException implements Exception {
  const PaymentGatewayException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class PaymentGateway {
  Future<PaymentGatewaySuccess> openCheckout(PaymentGatewayRequest request);
}
