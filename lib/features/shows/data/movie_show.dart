import 'package:intl/intl.dart';

class MovieShow {
  const MovieShow({
    required this.id,
    required this.theatreId,
    required this.movieId,
    required this.timing,
    required this.noOfSeats,
    required this.price,
    this.format,
    this.seatConfiguration,
  });

  factory MovieShow.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'];
    final seatValue = json['noOfSeats'];

    return MovieShow(
      id: _readString(json, const ['id', '_id']) ?? '',
      theatreId: _readString(json, const ['theatreId']) ?? '',
      movieId: _readString(json, const ['movieId']) ?? '',
      timing:
          DateTime.tryParse(_readString(json, const ['timing']) ?? '') ??
          DateTime.now(),
      noOfSeats: seatValue is int ? seatValue : int.tryParse('$seatValue') ?? 0,
      price: priceValue is num
          ? priceValue.toDouble()
          : double.tryParse('$priceValue') ?? 0,
      format: _readString(json, const ['format']),
      seatConfiguration: _readString(json, const ['seatConfiguration']),
    );
  }

  final String id;
  final String theatreId;
  final String movieId;
  final DateTime timing;
  final int noOfSeats;
  final double price;
  final String? format;
  final String? seatConfiguration;

  String get dateLabel => DateFormat('EEE, MMM d').format(timing);
  String get timeLabel => DateFormat('h:mm a').format(timing);
  String get formatLabel =>
      (format == null || format!.trim().isEmpty) ? 'Standard' : format!;
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
