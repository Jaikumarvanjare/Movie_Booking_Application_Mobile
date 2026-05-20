import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'movie_show.dart';

class ShowApiService {
  const ShowApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MovieShow>> fetchShows({
    String? theatreId,
    String? movieId,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (theatreId != null && theatreId.trim().isNotEmpty) {
      queryParameters['theatreId'] = theatreId.trim();
    }
    if (movieId != null && movieId.trim().isNotEmpty) {
      queryParameters['movieId'] = movieId.trim();
    }

    final response = await _apiClient.get(
      '/shows',
      queryParameters: queryParameters,
    );
    final items = _readList(response);
    return items.map(MovieShow.fromJson).toList(growable: false);
  }

  Future<MovieShow> fetchShowById(String id) async {
    final shows = await fetchShows();
    for (final show in shows) {
      if (show.id == id) {
        return show;
      }
    }
    throw const ApiException(message: 'Show not found.');
  }

  Future<MovieShow> createShow({
    required String theatreId,
    required String movieId,
    required DateTime timing,
    required int noOfSeats,
    required double price,
    String? seatConfiguration,
    String? format,
  }) async {
    final payload = <String, dynamic>{
      'theatreId': theatreId,
      'movieId': movieId,
      'timing': timing.toIso8601String(),
      'noOfSeats': noOfSeats,
      'price': price,
    };
    if (seatConfiguration != null) {
      payload['seatConfiguration'] = seatConfiguration;
    }
    if (format != null) {
      payload['format'] = format;
    }

    final response = await _apiClient.post('/shows', data: payload);
    return MovieShow.fromJson(_readObject(response));
  }

  Future<MovieShow> updateShow(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? price,
    String? seatConfiguration,
    String? format,
  }) async {
    final payload = <String, dynamic>{};
    if (timing != null) {
      payload['timing'] = timing.toIso8601String();
    }
    if (noOfSeats != null) {
      payload['noOfSeats'] = noOfSeats;
    }
    if (price != null) {
      payload['price'] = price;
    }
    if (seatConfiguration != null) {
      payload['seatConfiguration'] = seatConfiguration;
    }
    if (format != null) {
      payload['format'] = format;
    }

    final response = await _apiClient.patch('/shows/$id', data: payload);
    return MovieShow.fromJson(_readObject(response));
  }

  Future<void> deleteShow(String id) async {
    await _apiClient.delete('/shows/$id');
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
    for (final key in const ['shows', 'items', 'results', 'docs']) {
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
    for (final key in const ['show', 'item']) {
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
    message: 'The show response did not include show details.',
  );
}
