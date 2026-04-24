class BookingRecord {
  const BookingRecord({
    required this.id,
    required this.status,
    required this.totalCost,
  });

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    final totalCostValue = json['totalCost'];
    return BookingRecord(
      id: _readString(json, const ['id', '_id']) ?? '',
      status: _readString(json, const ['status']) ?? 'PROCESSING',
      totalCost: totalCostValue is num
          ? totalCostValue.toDouble()
          : double.tryParse('$totalCostValue') ?? 0,
    );
  }

  final String id;
  final String status;
  final double totalCost;
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
