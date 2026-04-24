import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'booking_draft.dart';
import 'booking_record.dart';

class BookingApiService {
  const BookingApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<BookingRecord> createBooking(BookingDraft bookingDraft) async {
    final response = await _apiClient.post(
      '/bookings',
      data: {
        'theatreId': bookingDraft.theatre.id,
        'movieId': bookingDraft.movie.id,
        'timing': bookingDraft.show.timing.toIso8601String(),
        'noOfSeats': bookingDraft.noOfSeats,
        if (bookingDraft.selectedSeats.isNotEmpty)
          'seat': _encodeSeatPayload(bookingDraft),
      },
    );

    return BookingRecord.fromJson(_readObject(response));
  }
}

Map<String, dynamic> _readObject(ApiResponse response) {
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
    message: 'The booking response did not include booking details.',
  );
}

String _encodeSeatPayload(BookingDraft bookingDraft) {
  final encoded = jsonEncode([
    for (final seat in bookingDraft.selectedSeats)
      {'rowNumber': seat.rowNumber, 'seatNumber': seat.seatNumber},
  ]);
  return encoded.replaceAll('"', "'");
}
