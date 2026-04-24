import 'booking_draft.dart';
import 'booking_record.dart';

abstract class BookingRepository {
  Future<BookingRecord> createBooking(BookingDraft bookingDraft);
}
