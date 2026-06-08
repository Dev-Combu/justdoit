import 'package:flutter_test/flutter_test.dart';

import 'package:justdoit/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Just verify the app builds without throwing.
    await tester.pumpWidget(const JustDoItApp());
  });
}

