import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/session_controller.dart';
import '../features/bookings/data/booking_repository.dart';
import '../features/movies/data/movie_repository.dart';
import '../features/payments/data/payment_gateway.dart';
import '../features/payments/data/payment_repository.dart';
import '../features/shows/data/show_repository.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/theatres/data/theatre_repository.dart';
import 'app_dependencies.dart';

class CineBookApp extends StatelessWidget {
  const CineBookApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: dependencies.authRepository),
        Provider<BookingRepository>.value(
          value: dependencies.bookingRepository,
        ),
        Provider<MovieRepository>.value(value: dependencies.movieRepository),
        Provider<PaymentGateway>.value(value: dependencies.paymentGateway),
        Provider<PaymentRepository>.value(
          value: dependencies.paymentRepository,
        ),
        Provider<TheatreRepository>.value(
          value: dependencies.theatreRepository,
        ),
        Provider<ShowRepository>.value(value: dependencies.showRepository),
        ChangeNotifierProvider<SessionController>.value(
          value: dependencies.sessionController,
        ),
      ],
      child: MaterialApp(
        title: 'CineBook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
