import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_api_service.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/remote_auth_repository.dart';
import '../features/auth/presentation/session_controller.dart';
import '../features/bookings/data/booking_api_service.dart';
import '../features/bookings/data/booking_repository.dart';
import '../features/bookings/data/remote_booking_repository.dart';
import '../features/movies/data/movie_api_service.dart';
import '../features/movies/data/movie_repository.dart';
import '../features/movies/data/remote_movie_repository.dart';
import '../features/payments/data/payment_api_service.dart';
import '../features/payments/data/payment_gateway.dart';
import '../features/payments/data/payment_repository.dart';
import '../features/payments/data/razorpay_payment_gateway.dart';
import '../features/payments/data/remote_payment_repository.dart';
import '../features/shows/data/remote_show_repository.dart';
import '../features/shows/data/show_api_service.dart';
import '../features/shows/data/show_repository.dart';
import '../features/theatres/data/remote_theatre_repository.dart';
import '../features/theatres/data/theatre_api_service.dart';
import '../features/theatres/data/theatre_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.bookingRepository,
    required this.movieRepository,
    required this.paymentGateway,
    required this.paymentRepository,
    required this.sessionController,
    required this.showRepository,
    required this.theatreRepository,
  });

  final AuthRepository authRepository;
  final BookingRepository bookingRepository;
  final MovieRepository movieRepository;
  final PaymentGateway paymentGateway;
  final PaymentRepository paymentRepository;
  final SessionController sessionController;
  final ShowRepository showRepository;
  final TheatreRepository theatreRepository;

  static Future<AppDependencies> create() async {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(
      config: AppConfig.fromEnvironment(),
      tokenStorage: tokenStorage,
    );
    final authRepository = RemoteAuthRepository(
      authApiService: AuthApiService(apiClient: apiClient),
      tokenStorage: tokenStorage,
    );
    final bookingRepository = RemoteBookingRepository(
      bookingApiService: BookingApiService(apiClient: apiClient),
    );
    final movieRepository = RemoteMovieRepository(
      movieApiService: MovieApiService(apiClient: apiClient),
    );
    final paymentRepository = RemotePaymentRepository(
      paymentApiService: PaymentApiService(apiClient: apiClient),
    );
    final paymentGateway = RazorpayPaymentGateway();
    final theatreRepository = RemoteTheatreRepository(
      theatreApiService: TheatreApiService(apiClient: apiClient),
    );
    final showRepository = RemoteShowRepository(
      showApiService: ShowApiService(apiClient: apiClient),
    );
    final sessionController = SessionController(authRepository: authRepository);
    await sessionController.restoreSession();

    return AppDependencies(
      authRepository: authRepository,
      bookingRepository: bookingRepository,
      movieRepository: movieRepository,
      paymentGateway: paymentGateway,
      paymentRepository: paymentRepository,
      sessionController: sessionController,
      showRepository: showRepository,
      theatreRepository: theatreRepository,
    );
  }

  factory AppDependencies.test({
    required AuthRepository authRepository,
    required BookingRepository bookingRepository,
    required MovieRepository movieRepository,
    required PaymentGateway paymentGateway,
    required PaymentRepository paymentRepository,
    required TheatreRepository theatreRepository,
    required ShowRepository showRepository,
    SessionController? sessionController,
  }) {
    return AppDependencies(
      authRepository: authRepository,
      bookingRepository: bookingRepository,
      movieRepository: movieRepository,
      paymentGateway: paymentGateway,
      paymentRepository: paymentRepository,
      sessionController:
          sessionController ??
          SessionController(authRepository: authRepository),
      showRepository: showRepository,
      theatreRepository: theatreRepository,
    );
  }
}
