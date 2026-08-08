import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_app/app/app.dart';

void main() {
  testWidgets('QuranApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: QuranApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
