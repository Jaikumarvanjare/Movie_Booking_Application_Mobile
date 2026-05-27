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
          'seat': bookingDraft.seatLabels,
      },
    );

    return BookingRecord.fromJson(_readObject(response));
  }

  Future<List<BookingRecord>> fetchBookings() async {
    final response = await _apiClient.get('/bookings');
    return _readList(
      response,
    ).map(BookingRecord.fromJson).toList(growable: false);
  }

  Future<List<BookingRecord>> fetchAllBookings() async {
    final response = await _apiClient.get('/bookings/all');
    return _readList(
      response,
    ).map(BookingRecord.fromJson).toList(growable: false);
  }

  Future<BookingRecord> fetchBookingById(String id) async {
    final response = await _apiClient.get('/bookings/$id');
    return BookingRecord.fromJson(_readObject(response));
  }

  Future<BookingRecord> updateBooking(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? totalCost,
    String? status,
    String? seat,
  }) async {
    final payload = <String, dynamic>{};
    if (timing != null) {
      payload['timing'] = timing.toIso8601String();
    }
    if (noOfSeats != null) {
      payload['noOfSeats'] = noOfSeats;
    }
    if (totalCost != null) {
      payload['totalCost'] = totalCost;
    }
    if (status != null) {
      payload['status'] = status;
    }
    if (seat != null) {
      payload['seat'] = seat;
    }

    final response = await _apiClient.patch('/bookings/$id', data: payload);
    return BookingRecord.fromJson(_readObject(response));
  }

  Future<BookingRecord> cancelBooking(String id) {
    return updateBooking(id, status: 'CANCELLED');
  }
}

List<Map<String, dynamic>> _readList(ApiResponse response) {
  final data = response.data;
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  if (data is Map) {
    final source = Map<String, dynamic>.from(data);
    for (final key in const ['bookings', 'items', 'results', 'docs']) {
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
