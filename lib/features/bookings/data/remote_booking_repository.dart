import 'booking_api_service.dart';
import 'booking_draft.dart';
import 'booking_record.dart';
import 'booking_repository.dart';

class RemoteBookingRepository implements BookingRepository {
  const RemoteBookingRepository({required BookingApiService bookingApiService})
    : _bookingApiService = bookingApiService;

  final BookingApiService _bookingApiService;

  @override
  Future<BookingRecord> createBooking(BookingDraft bookingDraft) {
    return _bookingApiService.createBooking(bookingDraft);
  }

  @override
  Future<List<BookingRecord>> fetchBookings() {
    return _bookingApiService.fetchBookings();
  }

  @override
  Future<List<BookingRecord>> fetchAllBookings() {
    return _bookingApiService.fetchAllBookings();
  }

  @override
  Future<BookingRecord> fetchBookingById(String id) {
    return _bookingApiService.fetchBookingById(id);
  }

  @override
  Future<BookingRecord> updateBooking(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? totalCost,
    String? status,
    String? seat,
  }) {
    return _bookingApiService.updateBooking(
      id,
      timing: timing,
      noOfSeats: noOfSeats,
      totalCost: totalCost,
      status: status,
      seat: seat,
    );
  }

  @override
  Future<BookingRecord> cancelBooking(String id) {
    return _bookingApiService.cancelBooking(id);
  }
}
