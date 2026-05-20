import 'movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> fetchMovies({String? query});

  Future<Movie> fetchMovieById(String id);

  Future<Movie> createMovie({
    required String name,
    required String description,
    required List<String> casts,
    required String trailerUrl,
    required String language,
    required String releaseDate,
    required String director,
    required String releaseStatus,
    required String poster,
  });

  Future<Movie> updateMovie(
    String id, {
    String? name,
    String? description,
    List<String>? casts,
    String? trailerUrl,
    String? language,
    String? releaseDate,
    String? director,
    String? releaseStatus,
    String? poster,
  });

  Future<void> deleteMovie(String id);
}
