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
}
