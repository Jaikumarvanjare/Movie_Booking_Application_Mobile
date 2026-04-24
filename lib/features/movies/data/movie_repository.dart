import 'movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> fetchMovies({String? query});

  Future<Movie> fetchMovieById(String id);
}
