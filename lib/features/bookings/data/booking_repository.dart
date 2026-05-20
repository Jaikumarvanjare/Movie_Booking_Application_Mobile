import 'booking_draft.dart';
import 'booking_record.dart';

abstract class BookingRepository {
  Future<BookingRecord> createBooking(BookingDraft bookingDraft);

  Future<List<BookingRecord>> fetchBookings();

  Future<List<BookingRecord>> fetchAllBookings();

  Future<BookingRecord> fetchBookingById(String id);

  Future<BookingRecord> updateBooking(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? totalCost,
    String? status,
    String? seat,
  });

  Future<BookingRecord> cancelBooking(String id);
}
