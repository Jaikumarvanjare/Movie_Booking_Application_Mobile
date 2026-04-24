class RazorpayOrder {
  const RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.keyId,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'];
    return RazorpayOrder(
      orderId:
          _readString(json, const ['id', 'orderId', 'razorpayOrderId']) ?? '',
      amount: amountValue is num
          ? amountValue.toDouble()
          : double.tryParse('$amountValue') ?? 0,
      currency: _readString(json, const ['currency']) ?? 'INR',
      keyId: _readString(json, const ['key', 'keyId', 'razorpayKeyId']),
    );
  }

  final String orderId;
  final double amount;
  final String currency;
  final String? keyId;
}

String? _readString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}
