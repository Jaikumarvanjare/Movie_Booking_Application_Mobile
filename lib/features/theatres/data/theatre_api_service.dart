import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../movies/data/movie.dart';
import 'theatre.dart';

class TheatreApiService {
  const TheatreApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Theatre>> fetchTheatres({
    String? movieId,
    String? city,
    int? pincode,
    String? name,
    int? limit,
    int? skip,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (movieId != null && movieId.trim().isNotEmpty) {
      queryParameters['movieId'] = movieId.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      queryParameters['city'] = city.trim();
    }
    if (pincode != null) {
      queryParameters['pincode'] = pincode;
    }
    if (name != null && name.trim().isNotEmpty) {
      queryParameters['name'] = name.trim();
    }
    if (limit != null) {
      queryParameters['limit'] = limit;
    }
    if (skip != null) {
      queryParameters['skip'] = skip;
    }

    final response = await _apiClient.get(
      '/theatres',
      queryParameters: queryParameters,
    );
    final items = _readList(response);
    return items.map(Theatre.fromJson).toList(growable: false);
  }

  Future<Theatre> fetchTheatreById(String id) async {
    final response = await _apiClient.get('/theatres/$id');
    return Theatre.fromJson(_readObject(response));
  }

  Future<Theatre> createTheatre({
    required String name,
    String? description,
    required String city,
    required int pincode,
    String? address,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'city': city,
      'pincode': pincode,
    };
    if (description != null) {
      payload['description'] = description;
    }
    if (address != null) {
      payload['address'] = address;
    }

    final response = await _apiClient.post('/theatres', data: payload);
    return Theatre.fromJson(_readObject(response));
  }

  Future<Theatre> updateTheatre(
    String id, {
    String? name,
    String? description,
    String? city,
    int? pincode,
    String? address,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name;
    }
    if (description != null) {
      payload['description'] = description;
    }
    if (city != null) {
      payload['city'] = city;
    }
    if (pincode != null) {
      payload['pincode'] = pincode;
    }
    if (address != null) {
      payload['address'] = address;
    }

    final response = await _apiClient.patch('/theatres/$id', data: payload);
    return Theatre.fromJson(_readObject(response));
  }

  Future<void> deleteTheatre(String id) async {
    await _apiClient.delete('/theatres/$id');
  }

  Future<Theatre> updateTheatreMovies(
    String id, {
    required List<String> movieIds,
    required bool insert,
  }) async {
    final response = await _apiClient.patch(
      '/theatres/$id/movies',
      data: {'movieIds': movieIds, 'insert': insert},
    );
    return Theatre.fromJson(_readObject(response));
  }

  Future<List<Movie>> fetchTheatreMovies(String id) async {
    final response = await _apiClient.get('/theatres/$id/movies');
    return _readList(response).map(Movie.fromJson).toList(growable: false);
  }

  Future<bool> checkTheatreMovie({
    required String theatreId,
    required String movieId,
  }) async {
    final response = await _apiClient.get(
      '/theatres/$theatreId/movies/$movieId',
    );
    final data = response.data;
    if (data is Map) {
      final value = Map<String, dynamic>.from(data)['isPresent'];
      return value == true;
    }
    return false;
  }
}

List<Map<String, dynamic>> _readList(ApiResponse response) {
  final data = response.data;
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  if (data is Map) {
    final source = Map<String, dynamic>.from(data);
    for (final key in const [
      'theatres',
      'movies',
      'items',
      'results',
      'docs',
    ]) {
      final value = source[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
  }
  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> _readObject(ApiResponse response) {
  final data = response.data;
  if (data is Map<String, dynamic>) {
    for (final key in const ['theatre', 'item']) {
      final nested = data[key];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
    }
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  throw const ApiException(
    message: 'The theatre response did not include theatre details.',
  );
}
