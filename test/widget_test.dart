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
}
