class BookingRecord {
  const BookingRecord({
    required this.id,
    required this.status,
    required this.totalCost,
    this.theatreId,
    this.movieId,
    this.userId,
    this.timing,
    this.noOfSeats,
    this.seat,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    final totalCostValue = json['totalCost'];
    final noOfSeatsValue = json['noOfSeats'];
    return BookingRecord(
      id: _readString(json, const ['id', '_id']) ?? '',
      status: _readString(json, const ['status']) ?? 'PROCESSING',
      totalCost: totalCostValue is num
          ? totalCostValue.toDouble()
          : double.tryParse('$totalCostValue') ?? 0,
      theatreId: _readString(json, const ['theatreId']),
      movieId: _readString(json, const ['movieId']),
      userId: _readString(json, const ['userId']),
      timing: DateTime.tryParse(_readString(json, const ['timing']) ?? ''),
      noOfSeats: noOfSeatsValue is int
          ? noOfSeatsValue
          : int.tryParse('$noOfSeatsValue'),
      seat: _readString(json, const ['seat']),
      createdAt: DateTime.tryParse(
        _readString(json, const ['createdAt']) ?? '',
      ),
      updatedAt: DateTime.tryParse(
        _readString(json, const ['updatedAt']) ?? '',
      ),
    );
  }

  final String id;
  final String status;
  final double totalCost;
  final String? theatreId;
  final String? movieId;
  final String? userId;
  final DateTime? timing;
  final int? noOfSeats;
  final String? seat;
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
