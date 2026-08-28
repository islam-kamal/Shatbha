import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Arabic wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('شطبة')),
      ),
    );
    expect(find.text('شطبة'), findsOneWidget);
  });
}
