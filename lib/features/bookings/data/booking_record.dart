import 'dart:convert';

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

  String get seatDisplayLabel {
    final rawSeat = seat?.trim();
    if (rawSeat == null || rawSeat.isEmpty) {
      return '';
    }

    final parsedLabels = _parseSeatLabels(rawSeat);
    if (parsedLabels.isNotEmpty) {
      return parsedLabels.join(', ');
    }

    return rawSeat;
  }
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

List<String> _parseSeatLabels(String rawSeat) {
  try {
    final decoded = jsonDecode(rawSeat.replaceAll("'", '"'));
    if (decoded is List) {
      return decoded.map(_labelFromSeatValue).whereType<String>().toList();
    }
  } catch (_) {
    // Fall back to comma-separated labels.
  }

  return rawSeat
      .split(',')
      .map((value) => value.trim())
      .where(
        (value) => RegExp(r'^[A-Z]\d+$', caseSensitive: false).hasMatch(value),
      )
      .map((value) => value.toUpperCase())
      .toList(growable: false);
}

String? _labelFromSeatValue(Object? value) {
  if (value is String &&
      RegExp(r'^[A-Z]\d+$', caseSensitive: false).hasMatch(value.trim())) {
    return value.trim().toUpperCase();
  }

  if (value is! Map) {
    return null;
  }

  final map = Map<String, dynamic>.from(value);
  final rowNumber = _readInt(map, const ['rowNumber', 'row']);
  final seatNumber = _readInt(map, const ['seatNumber', 'seat']);
  if (rowNumber == null || seatNumber == null || rowNumber < 1) {
    return null;
  }

  return '${String.fromCharCode(64 + rowNumber)}$seatNumber';
}

int? _readInt(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    final parsed = int.tryParse('$value');
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}
