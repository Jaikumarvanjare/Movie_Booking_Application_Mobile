import 'theatre.dart';

abstract class TheatreRepository {
  Future<List<Theatre>> fetchTheatres({required String movieId});
}
