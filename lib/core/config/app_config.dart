import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.razorpayKeyId});

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: _readEnv('API_BASE_URL')
          .ifEmpty(const String.fromEnvironment('API_BASE_URL', defaultValue: '')),
      razorpayKeyId: _readEnv('RAZORPAY_KEY_ID')
          .ifEmpty(const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '')),
    );
  }

  final String apiBaseUrl;
  final String razorpayKeyId;

  bool get isConfigured => apiBaseUrl.trim().isNotEmpty;
  bool get isRazorpayConfigured => razorpayKeyId.trim().isNotEmpty;
}

String _readEnv(String key) {
  try {
    return dotenv.env[key] ?? '';
  } catch (_) {
    return '';
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
