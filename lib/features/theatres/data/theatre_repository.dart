import '../../movies/data/movie.dart';
import 'theatre.dart';

abstract class TheatreRepository {
  Future<List<Theatre>> fetchTheatres({
    String? movieId,
    String? city,
    int? pincode,
    String? name,
    int? limit,
    int? skip,
  });

  Future<Theatre> fetchTheatreById(String id);

  Future<Theatre> createTheatre({
    required String name,
    String? description,
    required String city,
    required int pincode,
    String? address,
  });

  Future<Theatre> updateTheatre(
    String id, {
    String? name,
    String? description,
    String? city,
    int? pincode,
    String? address,
  });

  Future<void> deleteTheatre(String id);

  Future<Theatre> updateTheatreMovies(
    String id, {
    required List<String> movieIds,
    required bool insert,
  });

  Future<List<Movie>> fetchTheatreMovies(String id);

  Future<bool> checkTheatreMovie({
    required String theatreId,
    required String movieId,
  });
}
