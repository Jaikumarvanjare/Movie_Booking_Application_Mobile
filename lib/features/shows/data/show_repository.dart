import 'movie_show.dart';

abstract class ShowRepository {
  Future<List<MovieShow>> fetchShows({
    required String theatreId,
    required String movieId,
  });
}
