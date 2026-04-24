import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Fall back to --dart-define values when the local .env file is absent.
  }
  final dependencies = await AppDependencies.create();
  runApp(CineBookApp(dependencies: dependencies));
}
