import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'theatre.dart';

class TheatreApiService {
  const TheatreApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Theatre>> fetchTheatres({required String movieId}) async {
    final response = await _apiClient.get(
      '/theatres',
      queryParameters: {'movieId': movieId},
    );
    final items = _readList(response);
    return items.map(Theatre.fromJson).toList(growable: false);
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
    for (final key in const ['theatres', 'items', 'results', 'docs']) {
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
