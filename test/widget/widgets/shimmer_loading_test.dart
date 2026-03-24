import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShimmerLoading widget constructors', () {
    testWidgets('ShimmerDashboardLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: ShimmerDashboardLoading(),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerDashboardLoading), findsOneWidget);
    });

    testWidgets('ShimmerTeacherAnalyticsLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: ShimmerTeacherAnalyticsLoading(),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerTeacherAnalyticsLoading), findsOneWidget);
    });

    testWidgets('ShimmerStudentAnalyticsLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: ShimmerStudentAnalyticsLoading(),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerStudentAnalyticsLoading), findsOneWidget);
    });

    testWidgets('ShimmerAssignmentDetailLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: ShimmerAssignmentDetailLoading(),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerAssignmentDetailLoading), findsOneWidget);
    });

    testWidgets('ShimmerClassDetailLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: ShimmerClassDetailLoading(),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerClassDetailLoading), findsOneWidget);
    });
  });
}
