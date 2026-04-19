// ignore_for_file: depend_on_referenced_packages, unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// W0 stub — AiQuestionSettingsScreen will be created in Plan 03
// import 'package:ai_mls/presentation/views/settings/ai_question_settings_screen.dart';

void main() {
  group('AiQuestionSettingsScreen', () {
    group('Navigation', () {
      testWidgets(
        'displays API Key Setup tile',
        (tester) async {
          markTestSkipped(
            'W0 stub — implement when AiQuestionSettingsScreen exists (Plan 03)',
          );
        },
      );
      testWidgets(
        'tapping API Key Setup tile navigates to ApiKeySetupScreen',
        (tester) async {
          markTestSkipped(
            'W0 stub — implement when AiQuestionSettingsScreen exists (Plan 03)',
          );
        },
      );
      testWidgets(
        'displays Thư viện Tài liệu section',
        (tester) async {
          markTestSkipped(
            'W0 stub — implement when AiQuestionSettingsScreen exists (Plan 03)',
          );
        },
      );
      testWidgets(
        'displays Export Excel Template button',
        (tester) async {
          markTestSkipped(
            'W0 stub — implement when AiQuestionSettingsScreen exists (Plan 03)',
          );
        },
      );
    });

    group('Gear icon route', () {
      testWidgets(
        'gear icon in TeacherAiGenerateQuestionScreen navigates to ai-question-settings route',
        (tester) async {
          markTestSkipped(
            'W0 stub — implement after route change in Plan 03',
          );
        },
      );
    });

    group('File library', () {
      testWidgets(
        'shows shimmer loading while fetching teacher files',
        (tester) async {
          markTestSkipped('W0 stub — implement in Plan 05');
        },
      );
      testWidgets(
        'shows empty state when no files uploaded',
        (tester) async {
          markTestSkipped('W0 stub — implement in Plan 05');
        },
      );
    });
  });
}
