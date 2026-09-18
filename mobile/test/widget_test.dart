// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ootdee_app/main.dart';
import 'package:ootdee_app/features/wardrobe/add_wardrobe_screen.dart';

void main() {
  testWidgets('OOTDee app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const OOTDeeApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('AddWardrobeScreen renders camera and gallery options', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddWardrobeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Your Wardrobe 👗'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Add from Gallery'), findsOneWidget);
  });
}
