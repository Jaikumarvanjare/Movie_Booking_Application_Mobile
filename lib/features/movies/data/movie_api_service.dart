import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'movie.dart';

class MovieApiService {
  const MovieApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Movie>> fetchMovies({String? query}) async {
    final response = await _apiClient.get(
      '/movies',
      queryParameters: query == null || query.trim().isEmpty
          ? null
          : {'name': query.trim()},
    );
    final items = _readList(response);
    return items.map(Movie.fromJson).toList(growable: false);
  }

  Future<Movie> fetchMovieById(String id) async {
    final response = await _apiClient.get('/movies/$id');
    final item = _readObject(response);
    return Movie.fromJson(item);
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
    for (final key in const ['movies', 'items', 'results', 'docs']) {
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
    for (final key in const ['movie', 'item']) {
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
    message: 'Movie details were not returned by the server.',
  );
}
