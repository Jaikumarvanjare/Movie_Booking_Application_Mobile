import 'movie.dart';
import 'movie_api_service.dart';
import 'movie_repository.dart';

class RemoteMovieRepository implements MovieRepository {
  const RemoteMovieRepository({required MovieApiService movieApiService})
    : _movieApiService = movieApiService;

  final MovieApiService _movieApiService;

  @override
  Future<List<Movie>> fetchMovies({String? query}) {
    return _movieApiService.fetchMovies(query: query);
  }

  @override
  Future<Movie> fetchMovieById(String id) {
    return _movieApiService.fetchMovieById(id);
  }

  @override
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
  }) {
    return _movieApiService.createMovie(
      name: name,
      description: description,
      casts: casts,
      trailerUrl: trailerUrl,
      language: language,
      releaseDate: releaseDate,
      director: director,
      releaseStatus: releaseStatus,
      poster: poster,
    );
  }

  @override
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
  }) {
    return _movieApiService.updateMovie(
      id,
      name: name,
      description: description,
      casts: casts,
      trailerUrl: trailerUrl,
      language: language,
      releaseDate: releaseDate,
      director: director,
      releaseStatus: releaseStatus,
      poster: poster,
    );
  }

  @override
  Future<void> deleteMovie(String id) {
    return _movieApiService.deleteMovie(id);
  }
}
