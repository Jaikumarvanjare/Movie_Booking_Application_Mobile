class ApiResponse {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'],
      error: json['err'],
    );
  }

  final bool success;
  final String message;
  final Object? data;
  final Object? error;
}
