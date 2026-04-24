import 'theatre.dart';
import 'theatre_api_service.dart';
import 'theatre_repository.dart';

class RemoteTheatreRepository implements TheatreRepository {
  const RemoteTheatreRepository({required TheatreApiService theatreApiService})
    : _theatreApiService = theatreApiService;

  final TheatreApiService _theatreApiService;

  @override
  Future<List<Theatre>> fetchTheatres({required String movieId}) {
    return _theatreApiService.fetchTheatres(movieId: movieId);
  }
}
