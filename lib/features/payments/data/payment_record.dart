class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.status,
    required this.bookingId,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'];
    return PaymentRecord(
      id: _readString(json, const ['id', '_id']) ?? '',
      amount: amountValue is num
          ? amountValue.toDouble()
          : double.tryParse('$amountValue') ?? 0,
      status: _readString(json, const ['status']) ?? 'PROCESSING',
      bookingId: _readString(json, const ['bookingId']) ?? '',
      razorpayPaymentId: _readString(json, const ['razorpayPaymentId']),
      razorpayOrderId: _readString(json, const ['razorpayOrderId']),
      createdAt: DateTime.tryParse(
        _readString(json, const ['createdAt']) ?? '',
      ),
      updatedAt: DateTime.tryParse(
        _readString(json, const ['updatedAt']) ?? '',
      ),
    );
  }

  final String id;
  final double amount;
  final String status;
  final String bookingId;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
