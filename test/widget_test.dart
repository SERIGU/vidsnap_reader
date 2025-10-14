import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test: can pump a minimal widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
