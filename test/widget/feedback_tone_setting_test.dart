// ignore_for_file: depend_on_referenced_packages
import 'package:ai_mls/presentation/views/settings/widgets/feedback_tone_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// FeedbackToneSetting (Track 3) — control chọn giọng điệu phản hồi AI.
//
// Widget độc lập, KHÔNG đụng Supabase/providers → test pump trực tiếp với
// callback giả, không cần override repo. Đúng tinh thần "selecting one triggers
// the save callback".
// ---------------------------------------------------------------------------
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('kFeedbackToneOptions (mapper)', () {
    test('có đúng 3 giọng điệu khớp với edge buildToneInstruction', () {
      expect(kFeedbackToneOptions.length, 3);
      expect(
        kFeedbackToneOptions.map((o) => o.value).toList(),
        ['encouraging', 'direct', 'detailed'],
      );
    });

    test('mỗi option có label + mô tả không rỗng', () {
      for (final o in kFeedbackToneOptions) {
        expect(o.label.trim(), isNotEmpty);
        expect(o.description.trim(), isNotEmpty);
      }
    });
  });

  group('FeedbackToneSetting', () {
    testWidgets('hiển thị đủ 3 lựa chọn (Động viên / Thẳng thắn / Chi tiết)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          FeedbackToneSetting(value: 'encouraging', onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Động viên'), findsOneWidget);
      expect(find.text('Thẳng thắn'), findsOneWidget);
      expect(find.text('Chi tiết'), findsOneWidget);
    });

    testWidgets('chọn "Thẳng thắn" gọi onChanged với "direct"',
        (tester) async {
      String? saved;
      await tester.pumpWidget(
        _wrap(
          FeedbackToneSetting(
            value: 'encouraging',
            onChanged: (v) => saved = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('feedback_tone_direct')));
      await tester.pump();

      expect(saved, 'direct');
    });

    testWidgets('chọn "Chi tiết" gọi onChanged với "detailed"',
        (tester) async {
      String? saved;
      await tester.pumpWidget(
        _wrap(
          FeedbackToneSetting(
            value: 'encouraging',
            onChanged: (v) => saved = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('feedback_tone_detailed')));
      await tester.pump();

      expect(saved, 'detailed');
    });

    testWidgets('isSaving=true thì tap KHÔNG kích hoạt onChanged',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(
          FeedbackToneSetting(
            value: 'encouraging',
            isSaving: true,
            onChanged: (_) => called = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('feedback_tone_direct')));
      await tester.pump();

      expect(called, isFalse);
    });
  });
}
