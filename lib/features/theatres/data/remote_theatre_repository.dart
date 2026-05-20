import '../../movies/data/movie.dart';
import 'theatre.dart';
import 'theatre_api_service.dart';
import 'theatre_repository.dart';

class RemoteTheatreRepository implements TheatreRepository {
  const RemoteTheatreRepository({required TheatreApiService theatreApiService})
    : _theatreApiService = theatreApiService;

  final TheatreApiService _theatreApiService;

  @override
  Future<List<Theatre>> fetchTheatres({
    String? movieId,
    String? city,
    int? pincode,
    String? name,
    int? limit,
    int? skip,
  }) {
    return _theatreApiService.fetchTheatres(
      movieId: movieId,
      city: city,
      pincode: pincode,
      name: name,
      limit: limit,
      skip: skip,
    );
  }

  @override
  Future<Theatre> fetchTheatreById(String id) {
    return _theatreApiService.fetchTheatreById(id);
  }

  @override
  Future<Theatre> createTheatre({
    required String name,
    String? description,
    required String city,
    required int pincode,
    String? address,
  }) {
    return _theatreApiService.createTheatre(
      name: name,
      description: description,
      city: city,
      pincode: pincode,
      address: address,
    );
  }

  @override
  Future<Theatre> updateTheatre(
    String id, {
    String? name,
    String? description,
    String? city,
    int? pincode,
    String? address,
  }) {
    return _theatreApiService.updateTheatre(
      id,
      name: name,
      description: description,
      city: city,
      pincode: pincode,
      address: address,
    );
  }

  @override
  Future<void> deleteTheatre(String id) {
    return _theatreApiService.deleteTheatre(id);
  }

  @override
  Future<Theatre> updateTheatreMovies(
    String id, {
    required List<String> movieIds,
    required bool insert,
  }) {
    return _theatreApiService.updateTheatreMovies(
      id,
      movieIds: movieIds,
      insert: insert,
    );
  }

  @override
  Future<List<Movie>> fetchTheatreMovies(String id) {
    return _theatreApiService.fetchTheatreMovies(id);
  }

  @override
  Future<bool> checkTheatreMovie({
    required String theatreId,
    required String movieId,
  }) {
    return _theatreApiService.checkTheatreMovie(
      theatreId: theatreId,
      movieId: movieId,
    );
  }
}
