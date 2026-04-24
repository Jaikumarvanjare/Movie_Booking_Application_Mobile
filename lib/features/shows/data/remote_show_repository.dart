import 'movie_show.dart';
import 'show_api_service.dart';
import 'show_repository.dart';

class RemoteShowRepository implements ShowRepository {
  const RemoteShowRepository({required ShowApiService showApiService})
    : _showApiService = showApiService;

  final ShowApiService _showApiService;

  @override
  Future<List<MovieShow>> fetchShows({
    required String theatreId,
    required String movieId,
  }) {
    return _showApiService.fetchShows(theatreId: theatreId, movieId: movieId);
  }
}
