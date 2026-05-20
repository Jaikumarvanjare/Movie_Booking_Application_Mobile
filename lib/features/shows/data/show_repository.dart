import 'movie_show.dart';

abstract class ShowRepository {
  Future<List<MovieShow>> fetchShows({String? theatreId, String? movieId});

  Future<MovieShow> fetchShowById(String id);

  Future<MovieShow> createShow({
    required String theatreId,
    required String movieId,
    required DateTime timing,
    required int noOfSeats,
    required double price,
    String? seatConfiguration,
    String? format,
  });

  Future<MovieShow> updateShow(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? price,
    String? seatConfiguration,
    String? format,
  });

  Future<void> deleteShow(String id);
}
