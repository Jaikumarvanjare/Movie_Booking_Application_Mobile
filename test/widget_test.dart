import 'package:flutter_test/flutter_test.dart';

import 'package:movie_booking_frontend/app/app.dart';

void main() {
  testWidgets('CineBook splash shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CineBookApp());

    expect(find.text('CineBook Mobile'), findsOneWidget);
    expect(
      find.text('Book the next show without the desktop detour.'),
      findsOneWidget,
    );
    expect(find.text('Step 1 complete'), findsOneWidget);
  });
}
