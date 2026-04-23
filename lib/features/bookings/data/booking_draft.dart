import '../../movies/data/movie.dart';
import '../../seats/data/seat.dart';
import '../../shows/data/movie_show.dart';
import '../../theatres/data/theatre.dart';

class BookingDraft {
  const BookingDraft({
    required this.movie,
    required this.theatre,
    required this.show,
    required this.selectedSeats,
  });

  final Movie movie;
  final Theatre theatre;
  final MovieShow show;
  final List<Seat> selectedSeats;

  int get noOfSeats => selectedSeats.length;
  double get totalCost => noOfSeats * show.price;

  String get seatLabels {
    return selectedSeats.map((seat) => seat.label).join(', ');
  }
}
