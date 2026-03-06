import 'package:flutter_test/flutter_test.dart';

import 'package:plateful/main.dart';

void main() {
  testWidgets('app shows splash branding on startup', (tester) async {
    await tester.pumpWidget(const PlatefulApp());

    expect(find.text('Plateful'), findsOneWidget);
    expect(find.text('🍽️'), findsOneWidget);
  });
}
