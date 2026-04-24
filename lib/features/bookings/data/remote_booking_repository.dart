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
}
