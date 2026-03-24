import 'package:ai_mls/presentation/views/grading/scores_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScoresScreen', () {
    testWidgets('should render scaffold with app bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ScoresScreen(),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Điểm số'), findsOneWidget);
    });

    testWidgets('should show loading indicator when analytics is loading',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ScoresScreen(),
          ),
        ),
      );

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render app bar with correct properties', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ScoresScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 0);
    });

    testWidgets('should render with empty data after settling', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ScoresScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // App bar should be visible
      expect(find.text('Điểm số'), findsOneWidget);
    });

    testWidgets('should have correct scaffold background color',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ScoresScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });
  });

}
