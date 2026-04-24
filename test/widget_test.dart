import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_booking_application_mobile/app/app.dart';
import 'package:movie_booking_application_mobile/app/app_dependencies.dart';
import 'package:movie_booking_application_mobile/core/network/api_exception.dart';
import 'package:movie_booking_application_mobile/features/auth/data/auth_repository.dart';
import 'package:movie_booking_application_mobile/features/auth/data/auth_session.dart';
import 'package:movie_booking_application_mobile/features/bookings/data/booking_draft.dart';
import 'package:movie_booking_application_mobile/features/bookings/data/booking_record.dart';
import 'package:movie_booking_application_mobile/features/bookings/data/booking_repository.dart';
import 'package:movie_booking_application_mobile/features/movies/data/movie.dart';
import 'package:movie_booking_application_mobile/features/movies/data/movie_repository.dart';
import 'package:movie_booking_application_mobile/features/payments/data/payment_gateway.dart';
import 'package:movie_booking_application_mobile/features/payments/data/payment_repository.dart';
import 'package:movie_booking_application_mobile/features/payments/data/payment_verification_result.dart';
import 'package:movie_booking_application_mobile/features/payments/data/razorpay_order.dart';
import 'package:movie_booking_application_mobile/features/shows/data/movie_show.dart';
import 'package:movie_booking_application_mobile/features/shows/data/show_repository.dart';
import 'package:movie_booking_application_mobile/features/theatres/data/theatre.dart';
import 'package:movie_booking_application_mobile/features/theatres/data/theatre_repository.dart';

const _customerEmail = 'rahul@demo.com';
const _customerPassword = '1234567';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  AuthSession? _session;

  @override
  Future<AuthSession?> restoreSession() async {
    return _session;
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (email == _customerEmail && password == _customerPassword) {
      _session = AuthSession(
        token: 'test-token',
        user: const AppUser(
          email: _customerEmail,
          name: 'Rahul Demo',
          role: AppUserRole.customer,
          status: 'APPROVED',
        ),
      );
      return _session!;
    }

    throw const ApiException(message: 'Invalid email or password.');
  }

  @override
  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return 'Account created successfully. Please sign in.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String password,
  }) async {
    return 'Password updated successfully. Please sign in.';
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }
}

final _fakeMovies = [
  Movie(
    id: 'midnight-metro',
    name: 'Midnight Metro',
    description:
        'A suspended detective and a runaway projectionist uncover a city-wide conspiracy.',
    casts: const ['Aarav Mehta', 'Mira Sen', 'Kabir Rao'],
    trailerUrl: 'https://example.com/trailer',
    language: 'English',
    releaseDate: DateTime(2026, 4, 18),
    director: 'Nolan Verma',
    releaseStatus: 'NOW_SHOWING',
    poster: 'https://example.com/poster.png',
  ),
  Movie(
    id: 'last-balcony',
    name: 'The Last Balcony',
    description: 'A theatre mystery returns.',
    casts: const ['Pranav Shah', 'Leela Nair'],
    trailerUrl: '',
    language: 'English',
    releaseDate: DateTime(2026, 4, 30),
    director: 'Meera Dutt',
    releaseStatus: 'UPCOMING',
    poster: 'https://example.com/poster2.png',
  ),
];

class FakeMovieRepository implements MovieRepository {
  @override
  Future<List<Movie>> fetchMovies({String? query}) async {
    if (query == null || query.trim().isEmpty) {
      return _fakeMovies;
    }
    return _fakeMovies
        .where(
          (movie) =>
              movie.name.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList(growable: false);
  }

  @override
  Future<Movie> fetchMovieById(String id) async {
    return _fakeMovies.firstWhere((movie) => movie.id == id);
  }
}

const _fakeTheatres = [
  Theatre(
    id: 'nova-cinemas',
    name: 'Nova Cinemas',
    city: 'Pune',
    pincode: 411001,
    description: 'Premium recliners and Dolby screens.',
    address: 'MG Road, Camp, Pune',
  ),
];

class FakeTheatreRepository implements TheatreRepository {
  @override
  Future<List<Theatre>> fetchTheatres({required String movieId}) async {
    if (movieId == 'midnight-metro') {
      return _fakeTheatres;
    }
    return const <Theatre>[];
  }
}

final _fakeShows = [
  MovieShow(
    id: 'show-midnight-nova-1030',
    theatreId: 'nova-cinemas',
    movieId: 'midnight-metro',
    timing: DateTime(2026, 4, 24, 10, 30),
    noOfSeats: 72,
    price: 240,
    format: 'IMAX',
  ),
];

class FakeShowRepository implements ShowRepository {
  @override
  Future<List<MovieShow>> fetchShows({
    required String theatreId,
    required String movieId,
  }) async {
    return _fakeShows
        .where((show) => show.theatreId == theatreId && show.movieId == movieId)
        .toList(growable: false);
  }
}

class FakeBookingRepository implements BookingRepository {
  @override
  Future<BookingRecord> createBooking(BookingDraft bookingDraft) async {
    return BookingRecord(
      id: 'booking_123',
      status: 'PROCESSING',
      totalCost: bookingDraft.totalCost,
    );
  }
}

class FakePaymentRepository implements PaymentRepository {
  @override
  Future<RazorpayOrder> createRazorpayOrder({
    required String bookingId,
    required double amount,
  }) async {
    return RazorpayOrder(
      orderId: 'order_123',
      amount: amount,
      currency: 'INR',
      keyId: 'rzp_test_key',
    );
  }

  @override
  Future<PaymentVerificationResult> verifyRazorpayPayment({
    required String bookingId,
    required double amount,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    return PaymentVerificationResult(
      booking: BookingRecord(
        id: bookingId,
        status: 'SUCCESSFULL',
        totalCost: amount,
      ),
      message: 'Payment verified successfully.',
    );
  }
}

class FakePaymentGateway implements PaymentGateway {
  @override
  Future<PaymentGatewaySuccess> openCheckout(
    PaymentGatewayRequest request,
  ) async {
    return const PaymentGatewaySuccess(
      razorpayOrderId: 'order_123',
      razorpayPaymentId: 'pay_123',
      razorpaySignature: 'sig_123',
    );
  }
}

Widget buildTestApp() {
  return CineBookApp(
    dependencies: AppDependencies.test(
      authRepository: FakeAuthRepository(),
      bookingRepository: FakeBookingRepository(),
      movieRepository: FakeMovieRepository(),
      paymentGateway: FakePaymentGateway(),
      paymentRepository: FakePaymentRepository(),
      theatreRepository: FakeTheatreRepository(),
      showRepository: FakeShowRepository(),
    ),
  );
}

void main() {
  testWidgets('CineBook splash shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('CineBook Mobile'), findsOneWidget);
    expect(
      find.text('Book the next show without the desktop detour.'),
      findsOneWidget,
    );
    expect(find.text('Continue to login'), findsOneWidget);
  });

  testWidgets('Splash button opens login screen', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Valid login opens movie home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      _customerEmail,
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      _customerPassword,
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next show'), findsOneWidget);
    expect(find.text('Now showing'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('Invalid login stays on login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      _customerPassword,
    );
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Find your next show'), findsNothing);
    expect(find.text('Invalid email or password.'), findsOneWidget);
  });

  testWidgets('Movie card opens details screen', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      _customerEmail,
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      _customerPassword,
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Midnight Metro').first);
    await tester.pumpAndSettle();

    expect(find.text('Story'), findsOneWidget);
    expect(find.text('Cast'), findsOneWidget);
    expect(find.text('Movie details'), findsOneWidget);
    expect(find.text('Book seats'), findsOneWidget);
  });

  testWidgets('Movie details opens theatre, show, and seat selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      _customerEmail,
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      _customerPassword,
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Midnight Metro').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book seats'));
    await tester.pumpAndSettle();

    expect(find.text('Choose theatre'), findsOneWidget);
    expect(find.text('Nova Cinemas'), findsOneWidget);

    await tester.tap(find.text('Nova Cinemas'));
    await tester.pumpAndSettle();

    expect(find.text('Select show'), findsOneWidget);
    expect(find.text('Midnight Metro at Nova Cinemas'), findsOneWidget);
    expect(find.text('Continue to seats'), findsWidgets);

    await tester.tap(find.text('Continue to seats').first);
    await tester.pumpAndSettle();

    expect(find.text('Select seats'), findsOneWidget);
    expect(
      find.text('Midnight Metro at Nova Cinemas - 10:30 AM'),
      findsOneWidget,
    );
    expect(find.text('0 seats selected'), findsOneWidget);

    await tester.tap(find.text('A1'));
    await tester.tap(find.text('A2'));
    await tester.pumpAndSettle();

    expect(find.text('2 seats selected'), findsOneWidget);
    expect(find.text('A1, A2'), findsOneWidget);
    expect(find.text('Total Rs 480'), findsOneWidget);

    await tester.tap(find.text('Review booking'));
    await tester.pumpAndSettle();

    expect(find.text('Booking summary'), findsOneWidget);
    expect(
      find.text('Review your movie, theatre, show, and seats before payment.'),
      findsOneWidget,
    );
    expect(find.text('Selected seats'), findsOneWidget);
    expect(find.text('No. of seats'), findsOneWidget);
    expect(find.text('Total amount'), findsOneWidget);
    expect(find.text('Rs 480'), findsOneWidget);
    expect(find.text('Proceed to payment'), findsOneWidget);

    await tester.tap(find.text('Proceed to payment'));
    await tester.pumpAndSettle();

    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Razorpay checkout'), findsOneWidget);
    expect(find.text('Pay with Razorpay'), findsOneWidget);
    await tester.tap(find.text('Pay with Razorpay'));
    await tester.pumpAndSettle();

    expect(find.text('Payment successful'), findsOneWidget);
    expect(find.text('Payment ID'), findsOneWidget);
    expect(find.text('Order ID'), findsOneWidget);
    expect(find.text('Booking ID'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);

    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next show'), findsOneWidget);
    expect(find.text('Now showing'), findsOneWidget);
    expect(find.text('Email address'), findsNothing);
    expect(find.text('Password'), findsNothing);
  });
}
