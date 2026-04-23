import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_booking_application_mobile/app/app.dart';

void main() {
  testWidgets('CineBook splash shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CineBookApp());

    expect(find.text('CineBook Mobile'), findsOneWidget);
    expect(
      find.text('Book the next show without the desktop detour.'),
      findsOneWidget,
    );
    expect(find.text('Continue to login'), findsOneWidget);
  });

  testWidgets('Splash button opens login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CineBookApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Valid login opens movie home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CineBookApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      'guest@cinebook.app',
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      'secret1',
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Find your next show'), findsOneWidget);
    expect(find.text('Now showing'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('Non-demo login stays on login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CineBookApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      'secret1',
    );
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Find your next show'), findsNothing);
    expect(
      find.text('Use the demo login until backend auth is connected.'),
      findsOneWidget,
    );
  });

  testWidgets('Movie card opens details screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CineBookApp());

    await tester.tap(find.text('Continue to login'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('loginEmailField')),
      'guest@cinebook.app',
    );
    await tester.enterText(
      find.byKey(const ValueKey('loginPasswordField')),
      'secret1',
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Midnight Metro').first);
    await tester.pumpAndSettle();

    expect(find.text('Story'), findsOneWidget);
    expect(find.text('Cast'), findsOneWidget);
    expect(find.text('Available formats'), findsOneWidget);
    expect(find.text('Select showtime'), findsOneWidget);
    expect(find.text('Book seats'), findsOneWidget);
  });
}
