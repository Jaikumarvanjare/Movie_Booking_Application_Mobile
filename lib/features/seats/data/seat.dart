import 'dart:convert';
import 'dart:math' as math;

import '../../shows/data/movie_show.dart';

class Seat {
  const Seat({
    required this.rowNumber,
    required this.seatNumber,
    required this.isBooked,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      rowNumber: _readInt(json, const ['rowNumber', 'row']) ?? 1,
      seatNumber: _readInt(json, const ['seatNumber', 'seat']) ?? 1,
      isBooked: _readBool(json, const ['isBooked', 'booked']) ?? false,
    );
  }

  final int rowNumber;
  final int seatNumber;
  final bool isBooked;

  String get id => '$rowNumber-$seatNumber';
  String get label => '${String.fromCharCode(64 + rowNumber)}$seatNumber';
}

List<Seat> seatsForShow(MovieShow show) {
  final parsedSeats = _parseSeatConfiguration(show.seatConfiguration);
  if (parsedSeats.isNotEmpty) {
    return parsedSeats;
  }

  if (show.noOfSeats <= 0) {
    return const <Seat>[];
  }

  // If the backend does not provide seatConfiguration yet, infer a simple
  // layout directly from the live seat count.
  const seatsPerRow = 8;
  final rows = (show.noOfSeats / seatsPerRow).ceil();
  final totalSeats = math.max(show.noOfSeats, rows * seatsPerRow);

  return [
    for (var index = 0; index < totalSeats; index++)
      Seat(
        rowNumber: (index ~/ seatsPerRow) + 1,
        seatNumber: (index % seatsPerRow) + 1,
        isBooked: false,
      ),
  ];
}

List<Seat> _parseSeatConfiguration(String? rawConfiguration) {
  if (rawConfiguration == null || rawConfiguration.trim().isEmpty) {
    return const <Seat>[];
  }

  try {
    final decoded = jsonDecode(_normalizeJsonishString(rawConfiguration));
    return _parseDecodedConfiguration(decoded);
  } catch (_) {
    return const <Seat>[];
  }
}

List<Seat> _parseDecodedConfiguration(Object? decoded) {
  if (decoded is List) {
    return decoded
        .whereType<Map>()
        .map((item) => Seat.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  if (decoded is! Map) {
    return const <Seat>[];
  }

  final map = Map<String, dynamic>.from(decoded);

  final backendRows = map['rows'];
  if (backendRows is List) {
    return _parseBackendRows(backendRows);
  }

  for (final key in const ['seats', 'layout']) {
    final nested = map[key];
    if (nested is List) {
      return _parseLayoutList(
        nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false),
        bookedSeats: _parseBookedSeatIds(map),
      );
    }
  }

  final rows = _readInt(map, const ['rows', 'rowCount']);
  final seatsPerRow = _readInt(map, const [
    'seatsPerRow',
    'columns',
    'seatCount',
  ]);
  if (rows != null && seatsPerRow != null) {
    final bookedSeats = _parseBookedSeatIds(map);
    return [
      for (var row = 1; row <= rows; row++)
        for (var seat = 1; seat <= seatsPerRow; seat++)
          Seat(
            rowNumber: row,
            seatNumber: seat,
            isBooked: bookedSeats.contains('$row-$seat'),
          ),
    ];
  }

  return const <Seat>[];
}

List<Seat> _parseBackendRows(List<dynamic> rows) {
  final seats = <Seat>[];
  for (final rowValue in rows) {
    if (rowValue is! Map) {
      continue;
    }
    final row = Map<String, dynamic>.from(rowValue);
    final rowNumber = _readInt(row, const ['number', 'rowNumber', 'row']) ?? 1;
    final rowSeats = row['seats'];
    if (rowSeats is! List) {
      continue;
    }

    for (final seatValue in rowSeats) {
      if (seatValue is! Map) {
        continue;
      }
      final seat = Map<String, dynamic>.from(seatValue);
      final seatNumber =
          _readInt(seat, const ['number', 'seatNumber', 'seat']) ?? 1;
      final seatStatus = _readInt(seat, const ['status']) ?? 1;
      seats.add(
        Seat(
          rowNumber: rowNumber,
          seatNumber: seatNumber,
          isBooked: seatStatus == 2,
        ),
      );
    }
  }
  return seats;
}

List<Seat> _parseLayoutList(
  List<Map<String, dynamic>> layout, {
  required Set<String> bookedSeats,
}) {
  if (layout.isEmpty) {
    return const <Seat>[];
  }

  final looksLikeSeatList =
      layout.first.containsKey('seatNumber') ||
      layout.first.containsKey('seat');
  if (looksLikeSeatList) {
    return layout.map(Seat.fromJson).toList(growable: false);
  }

  final seats = <Seat>[];
  for (final row in layout) {
    final rowNumber = _readInt(row, const ['rowNumber', 'row']) ?? 1;
    final seatCount =
        _readInt(row, const ['seatCount', 'seatsPerRow', 'columns']) ?? 0;
    for (var seat = 1; seat <= seatCount; seat++) {
      seats.add(
        Seat(
          rowNumber: rowNumber,
          seatNumber: seat,
          isBooked: bookedSeats.contains('$rowNumber-$seat'),
        ),
      );
    }
  }
  return seats;
}

Set<String> _parseBookedSeatIds(Map<String, dynamic> map) {
  for (final key in const ['bookedSeats', 'bookedSeatIds', 'occupiedSeats']) {
    final value = map[key];
    if (value is List) {
      return value.map(_seatKeyFromDynamic).whereType<String>().toSet();
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(_normalizeJsonishString(value));
        if (decoded is List) {
          return decoded.map(_seatKeyFromDynamic).whereType<String>().toSet();
        }
      } catch (_) {
        // Ignore malformed booked-seat payloads and continue with an empty set.
      }
    }
  }
  return <String>{};
}

String _normalizeJsonishString(String rawValue) {
  return rawValue.replaceAll("'", '"');
}

String? _seatKeyFromDynamic(Object? value) {
  if (value is String) {
    final match = RegExp(r'^([A-Z])(\d+)$').firstMatch(value.toUpperCase());
    if (match != null) {
      final row = match.group(1)!.codeUnitAt(0) - 64;
      final seat = int.tryParse(match.group(2)!);
      if (seat != null) {
        return '$row-$seat';
      }
    }

    final direct = RegExp(r'^(\d+)-(\d+)$').firstMatch(value);
    if (direct != null) {
      return value;
    }
  }

  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final row = _readInt(map, const ['rowNumber', 'row']);
    final seat = _readInt(map, const ['seatNumber', 'seat']);
    if (row != null && seat != null) {
      return '$row-$seat';
    }
  }

  return null;
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

bool? _readBool(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      if (value.toLowerCase() == 'true') {
        return true;
      }
      if (value.toLowerCase() == 'false') {
        return false;
      }
    }
  }
  return null;
}
