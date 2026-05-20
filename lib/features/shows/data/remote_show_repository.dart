import 'movie_show.dart';
import 'show_api_service.dart';
import 'show_repository.dart';

class RemoteShowRepository implements ShowRepository {
  const RemoteShowRepository({required ShowApiService showApiService})
    : _showApiService = showApiService;

  final ShowApiService _showApiService;

  @override
  Future<List<MovieShow>> fetchShows({String? theatreId, String? movieId}) {
    return _showApiService.fetchShows(theatreId: theatreId, movieId: movieId);
  }

  @override
  Future<MovieShow> fetchShowById(String id) {
    return _showApiService.fetchShowById(id);
  }

  @override
  Future<MovieShow> createShow({
    required String theatreId,
    required String movieId,
    required DateTime timing,
    required int noOfSeats,
    required double price,
    String? seatConfiguration,
    String? format,
  }) {
    return _showApiService.createShow(
      theatreId: theatreId,
      movieId: movieId,
      timing: timing,
      noOfSeats: noOfSeats,
      price: price,
      seatConfiguration: seatConfiguration,
      format: format,
    );
  }

  @override
  Future<MovieShow> updateShow(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? price,
    String? seatConfiguration,
    String? format,
  }) {
    return _showApiService.updateShow(
      id,
      timing: timing,
      noOfSeats: noOfSeats,
      price: price,
      seatConfiguration: seatConfiguration,
      format: format,
    );
  }

  @override
  Future<void> deleteShow(String id) {
    return _showApiService.deleteShow(id);
  }
}
