import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test renders a simple widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: Text('0'))),
    ));

    expect(find.text('0'), findsOneWidget);
  });
}
