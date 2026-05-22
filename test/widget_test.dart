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
import 'package:movie_booking_application_mobile/features/payments/data/payment_record.dart';
import 'package:movie_booking_application_mobile/features/payments/data/payment_repository.dart';
import 'package:movie_booking_application_mobile/features/payments/data/payment_verification_result.dart';
import 'package:movie_booking_application_mobile/features/payments/data/razorpay_order.dart';
import 'package:movie_booking_application_mobile/features/shows/data/movie_show.dart';
import 'package:movie_booking_application_mobile/features/shows/data/show_repository.dart';
import 'package:movie_booking_application_mobile/features/theatres/data/theatre.dart';
import 'package:movie_booking_application_mobile/features/theatres/data/theatre_repository.dart';

const _customerEmail = 'rahul@demo.com';
const _customerPassword = '1234567';
const _updatedCustomerName = 'Rahul Profile';
final _memberSince = DateTime(2026, 4, 24, 10);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  AuthSession? _session;
  String _savedPassword = _customerPassword;
  String _savedName = 'Rahul Demo';

  AppUser get _currentUser => AppUser(
    id: 'customer_123',
    email: _customerEmail,
    name: _savedName,
    role: AppUserRole.customer,
    status: 'APPROVED',
    createdAt: _memberSince,
  );

  @override
  Future<AuthSession?> restoreSession() async {
    return _session;
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (email == _customerEmail && password == _savedPassword) {
      _session = AuthSession(token: 'test-token', user: _currentUser);
      return _session!;
    }

    throw const ApiException(message: 'Invalid email or password.');
  }

  @override
  Future<AppUser> fetchProfile() async {
    _ensureSession();
    final user = _currentUser;
    _session = _session!.copyWith(user: user);
    return user;
  }

  @override
  Future<AppUser> updateProfile({required String name}) async {
    _ensureSession();
    final trimmedName = name.trim();
    if (trimmedName.length < 2) {
      throw const ApiException(message: 'Name must be at least 2 characters.');
    }

    _savedName = trimmedName;
    final user = _currentUser;
    _session = _session!.copyWith(user: user);
    return user;
  }

  @override
  Future<List<AppUser>> fetchUsers({String? search}) async {
    return [_currentUser];
  }

  @override
  Future<AppUser> updateUser(
    String id, {
    AppUserRole? role,
    String? status,
  }) async {
    return _currentUser.copyWith(
      role: role ?? _currentUser.role,
      status: status ?? _currentUser.status,
    );
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
  Future<String> forgotPassword({required String email}) async {
    return 'OTP sent to your email.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _savedPassword = newPassword;
    return 'Password updated successfully. Please sign in.';
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _ensureSession();
    if (currentPassword != _savedPassword) {
      throw const ApiException(message: 'Current password is incorrect.');
    }
    if (newPassword.length < 6) {
      throw const ApiException(
        message: 'Password must be at least 6 characters.',
      );
    }

    _savedPassword = newPassword;
    return 'Password changed successfully';
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }

  void _ensureSession() {
    if (_session == null) {
      throw const ApiException(message: 'You need to sign in again.');
    }
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
  final List<Movie> _movies = List<Movie>.from(_fakeMovies);

  @override
  Future<List<Movie>> fetchMovies({String? query}) async {
    if (query == null || query.trim().isEmpty) {
      return _movies;
    }
    return _movies
        .where(
          (movie) =>
              movie.name.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList(growable: false);
  }

  @override
  Future<Movie> fetchMovieById(String id) async {
    return _movies.firstWhere((movie) => movie.id == id);
  }

  @override
  Future<Movie> createMovie({
    required String name,
    required String description,
    required List<String> casts,
    required String trailerUrl,
    required String language,
    required String releaseDate,
    required String director,
    required String releaseStatus,
    required String poster,
  }) async {
    final movie = Movie(
      id: name.toLowerCase().replaceAll(' ', '-'),
      name: name,
      description: description,
      casts: casts,
      trailerUrl: trailerUrl,
      language: language,
      releaseDate: DateTime.tryParse(releaseDate),
      director: director,
      releaseStatus: releaseStatus,
      poster: poster,
    );
    _movies.add(movie);
    return movie;
  }

  @override
  Future<Movie> updateMovie(
    String id, {
    String? name,
    String? description,
    List<String>? casts,
    String? trailerUrl,
    String? language,
    String? releaseDate,
    String? director,
    String? releaseStatus,
    String? poster,
  }) async {
    return fetchMovieById(id);
  }

  @override
  Future<void> deleteMovie(String id) async {
    _movies.removeWhere((movie) => movie.id == id);
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
  Future<List<Theatre>> fetchTheatres({
    String? movieId,
    String? city,
    int? pincode,
    String? name,
    int? limit,
    int? skip,
  }) async {
    if (movieId == 'midnight-metro') {
      return _fakeTheatres;
    }
    return const <Theatre>[];
  }

  @override
  Future<Theatre> fetchTheatreById(String id) async {
    return _fakeTheatres.firstWhere((theatre) => theatre.id == id);
  }

  @override
  Future<Theatre> createTheatre({
    required String name,
    String? description,
    required String city,
    required int pincode,
    String? address,
  }) async {
    return Theatre(
      id: name.toLowerCase().replaceAll(' ', '-'),
      name: name,
      city: city,
      pincode: pincode,
      description: description,
      address: address,
    );
  }

  @override
  Future<Theatre> updateTheatre(
    String id, {
    String? name,
    String? description,
    String? city,
    int? pincode,
    String? address,
  }) async {
    return fetchTheatreById(id);
  }

  @override
  Future<void> deleteTheatre(String id) async {}

  @override
  Future<Theatre> updateTheatreMovies(
    String id, {
    required List<String> movieIds,
    required bool insert,
  }) async {
    return fetchTheatreById(id);
  }

  @override
  Future<List<Movie>> fetchTheatreMovies(String id) async {
    return _fakeMovies;
  }

  @override
  Future<bool> checkTheatreMovie({
    required String theatreId,
    required String movieId,
  }) async {
    return theatreId == 'nova-cinemas' && movieId == 'midnight-metro';
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
    String? theatreId,
    String? movieId,
  }) async {
    return _fakeShows
        .where((show) => show.theatreId == theatreId && show.movieId == movieId)
        .toList(growable: false);
  }

  @override
  Future<MovieShow> fetchShowById(String id) async {
    return _fakeShows.firstWhere((show) => show.id == id);
  }

  @override
  Future<MovieShow> createShow({
    required String theatreId,
    required String movieId,
    required DateTime timing,
    required int noOfSeats,
    required double price,
    String? seatConfiguration,
    String? format,
  }) async {
    return MovieShow(
      id: 'show_123',
      theatreId: theatreId,
      movieId: movieId,
      timing: timing,
      noOfSeats: noOfSeats,
      price: price,
      seatConfiguration: seatConfiguration,
      format: format,
    );
  }

  @override
  Future<MovieShow> updateShow(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? price,
    String? seatConfiguration,
    String? format,
  }) async {
    return fetchShowById(id);
  }

  @override
  Future<void> deleteShow(String id) async {}
}

class FakeBookingRepository implements BookingRepository {
  final List<BookingRecord> _bookings = [];

  @override
  Future<BookingRecord> createBooking(BookingDraft bookingDraft) async {
    final booking = BookingRecord(
      id: 'booking_123',
      status: 'PROCESSING',
      totalCost: bookingDraft.totalCost,
      theatreId: bookingDraft.theatre.id,
      movieId: bookingDraft.movie.id,
      timing: bookingDraft.show.timing,
      noOfSeats: bookingDraft.noOfSeats,
      seat: bookingDraft.seatLabels,
    );
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<List<BookingRecord>> fetchBookings() async {
    return _bookings;
  }

  @override
  Future<List<BookingRecord>> fetchAllBookings() async {
    return _bookings;
  }

  @override
  Future<BookingRecord> fetchBookingById(String id) async {
    return _bookings.firstWhere((booking) => booking.id == id);
  }

  @override
  Future<BookingRecord> updateBooking(
    String id, {
    DateTime? timing,
    int? noOfSeats,
    double? totalCost,
    String? status,
    String? seat,
  }) async {
    final currentIndex = _bookings.indexWhere((booking) => booking.id == id);
    final current = currentIndex == -1 ? null : _bookings[currentIndex];
    final updated = BookingRecord(
      id: id,
      status: status ?? current?.status ?? 'PROCESSING',
      totalCost: totalCost ?? current?.totalCost ?? 0,
      theatreId: current?.theatreId,
      movieId: current?.movieId,
      userId: current?.userId,
      timing: timing ?? current?.timing,
      noOfSeats: noOfSeats ?? current?.noOfSeats,
      seat: seat ?? current?.seat,
    );
    if (currentIndex == -1) {
      _bookings.add(updated);
    } else {
      _bookings[currentIndex] = updated;
    }
    return updated;
  }

  @override
  Future<BookingRecord> cancelBooking(String id) async {
    return updateBooking(id, status: 'CANCELLED');
  }
}

class FakePaymentRepository implements PaymentRepository {
  @override
  Future<PaymentRecord> createPayment({
    required String bookingId,
    required double amount,
    String? razorpayPaymentId,
    String? razorpayOrderId,
  }) async {
    return PaymentRecord(
      id: 'payment_123',
      amount: amount,
      status: 'SUCCESSFULL',
      bookingId: bookingId,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
    );
  }

  @override
  Future<List<PaymentRecord>> fetchPayments() async {
    return const <PaymentRecord>[];
  }

  @override
  Future<PaymentRecord> fetchPaymentById(String id) async {
    return const PaymentRecord(
      id: 'payment_123',
      amount: 240,
      status: 'SUCCESSFULL',
      bookingId: 'booking_123',
    );
  }

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

Future<void> _openLoginScreen(WidgetTester tester) async {
  await tester.tap(find.text('Continue to login'));
  await tester.pumpAndSettle();
}

Future<void> _signInAsCustomer(WidgetTester tester) async {
  await _openLoginScreen(tester);
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
}

Future<void> _openProfileTab(WidgetTester tester) async {
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CineBook splash shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('CineBook Mobile'), findsOneWidget);
    expect(find.text('Movie tickets, made simple.'), findsOneWidget);
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

    await tester.tap(find.text('Tickets'));
    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('A1, A2'), findsOneWidget);
  });

  testWidgets('Profile tab renders customer details and member since', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await _signInAsCustomer(tester);
    expect(find.text('Profile'), findsOneWidget);

    await _openProfileTab(tester);

    expect(find.text('Rahul Demo'), findsWidgets);
    expect(find.text(_customerEmail), findsWidgets);
    expect(find.text('Customer'), findsWidgets);
    expect(find.text('Approved'), findsWidgets);
    expect(find.text('Member since'), findsOneWidget);
    expect(find.text('Apr 24, 2026'), findsOneWidget);
  });

  testWidgets('Edit profile updates the displayed name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await _signInAsCustomer(tester);
    await _openProfileTab(tester);

    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('editProfileNameField')),
      _updatedCustomerName,
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Profile updated successfully'), findsOneWidget);
    expect(find.text(_updatedCustomerName), findsWidgets);
  });

  testWidgets('Change password validates inputs and succeeds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await _signInAsCustomer(tester);
    await _openProfileTab(tester);

    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('changeCurrentPasswordField')),
      _customerPassword,
    );
    await tester.enterText(
      find.byKey(const ValueKey('changeNewPasswordField')),
      '123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('changeConfirmPasswordField')),
      '123',
    );
    await tester.tap(find.text('Update password'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('changeNewPasswordField')),
      'newpass1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('changeConfirmPasswordField')),
      'different1',
    );
    await tester.tap(find.text('Update password'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('changeConfirmPasswordField')),
      'newpass1',
    );
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(find.text('Password changed successfully'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('Logout returns the user to the login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await _signInAsCustomer(tester);
    await _openProfileTab(tester);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Find your next show'), findsNothing);
  });
}
