import 'package:ai_mls/presentation/providers/workspace_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests cho models của workspace học sinh.
///
/// Chỉ test các đơn vị tinh khiết (enum, parsing, copyWith, getter) — không
/// chạm Supabase. Các bug đã sửa được khoá bằng test:
///   • BUG-1: WorkspaceState lưu sessionId để workspace_provider truyền xuống
///     getDistributionDetail (variant đúng attempt).
///   • Format mới `selected_choice_ids` cùng tồn tại với format cũ
///     `selected_choices` (đếm câu đã trả lời không phụ thuộc format).
///   • Choice id int / String / fallback index — không crash nếu thiếu.
void main() {
  WorkspaceState makeBaseState({
    String? sessionId,
    List<QuestionState> questions = const [],
    Map<String, dynamic> answers = const {},
    WorkspaceSubmissionStatus submissionStatus =
        WorkspaceSubmissionStatus.inProgress,
    int attempt = 1,
    int? maxAttempts,
    DateTime? dueAt,
    bool allowLate = true,
  }) {
    return WorkspaceState(
      distributionId: 'dist-1',
      sessionId: sessionId,
      assignmentTitle: 'Bài tập kiểm tra',
      dueAt: dueAt,
      allowLate: allowLate,
      questions: questions,
      answers: answers,
      uploadedFiles: const [],
      submissionStatus: submissionStatus,
      savingStatus: SavingStatus.idle,
      attempt: attempt,
      maxAttempts: maxAttempts,
    );
  }

  QuestionState makeQuestion(String id, {String type = 'multiple_choice'}) {
    return QuestionState(
      id: id,
      content: 'Câu hỏi $id',
      type: type,
      points: 1.0,
      choices: const [],
    );
  }

  group('Enum sanity', () {
    test('SavingStatus có đủ 4 giá trị', () {
      expect(SavingStatus.values, hasLength(4));
      expect(
        SavingStatus.values.toSet(),
        {
          SavingStatus.idle,
          SavingStatus.saving,
          SavingStatus.saved,
          SavingStatus.error,
        },
      );
    });

    test('WorkspaceSubmissionStatus có đủ 4 giá trị', () {
      expect(WorkspaceSubmissionStatus.values, hasLength(4));
      expect(
        WorkspaceSubmissionStatus.values.toSet(),
        {
          WorkspaceSubmissionStatus.inProgress,
          WorkspaceSubmissionStatus.submitting,
          WorkspaceSubmissionStatus.submitted,
          WorkspaceSubmissionStatus.error,
        },
      );
    });
  });

  group('WorkspaceState constructor', () {
    test('attempt mặc định = 1 khi không truyền', () {
      final s = makeBaseState();
      expect(s.attempt, 1);
      expect(s.maxAttempts, isNull);
      expect(s.sessionId, isNull);
      expect(s.savingStatus, SavingStatus.idle);
    });

    test('lưu được sessionId (BUG-1: cần để truyền xuống getDistributionDetail)',
        () {
      final s = makeBaseState(sessionId: 'session-abc');
      expect(s.sessionId, 'session-abc');
    });
  });

  group('WorkspaceState.copyWith', () {
    test('chỉ override field được truyền vào, giữ nguyên các field khác', () {
      final base = makeBaseState(sessionId: 'sess-1', attempt: 2);
      final next = base.copyWith(attempt: 3);
      expect(next.attempt, 3);
      expect(next.sessionId, 'sess-1');
      expect(next.distributionId, 'dist-1');
      expect(next.savingStatus, SavingStatus.idle);
    });

    test('có thể đổi sessionId qua copyWith', () {
      final base = makeBaseState(sessionId: 'sess-1');
      final next = base.copyWith(sessionId: 'sess-2');
      expect(next.sessionId, 'sess-2');
    });

    test('đổi savingStatus + submissionStatus đồng thời', () {
      final base = makeBaseState();
      final next = base.copyWith(
        savingStatus: SavingStatus.saving,
        submissionStatus: WorkspaceSubmissionStatus.submitting,
      );
      expect(next.savingStatus, SavingStatus.saving);
      expect(next.submissionStatus, WorkspaceSubmissionStatus.submitting);
    });
  });

  group('WorkspaceState.answeredCount', () {
    test('không có câu trả lời → 0', () {
      final s = makeBaseState(
        questions: [makeQuestion('q1'), makeQuestion('q2')],
      );
      expect(s.answeredCount, 0);
      expect(s.totalQuestions, 2);
    });

    test('Map answer (MCQ format mới selected_choice_ids) được đếm', () {
      final q = makeQuestion('q1');
      final s = makeBaseState(
        questions: [q],
        answers: {
          q.id: {
            'selected_choice_ids': [0]
          }
        },
      );
      expect(s.answeredCount, 1);
    });

    test('Map answer rỗng (không có choice nào) vẫn đếm là 1 — Map != null',
        () {
      // Hành vi hiện tại của getter: object Map non-null đếm là answered. Đây
      // là quy ước — fix lúc nào sẽ thay test, hiện tại lock behavior.
      final q = makeQuestion('q1');
      final s = makeBaseState(
        questions: [q],
        answers: {
          q.id: {'selected_choice_ids': []}
        },
      );
      expect(s.answeredCount, 1);
    });

    test('String rỗng không đếm; String non-empty đếm', () {
      final q1 = makeQuestion('q1', type: 'essay');
      final q2 = makeQuestion('q2', type: 'essay');
      final s = makeBaseState(
        questions: [q1, q2],
        answers: {q1.id: '', q2.id: 'Đáp án ngắn'},
      );
      expect(s.answeredCount, 1);
    });

    test('List non-empty đếm', () {
      final q1 = makeQuestion('q1');
      final s = makeBaseState(
        questions: [q1],
        answers: {q1.id: ['choice-0']},
      );
      expect(s.answeredCount, 1);
    });

    test('List rỗng (quirk hiện tại): vẫn đếm vì rơi vào nhánh "is! String"',
        () {
      // Behavior gốc của getter: nhánh String empty/non-empty → count theo
      // empty; nhánh List empty/non-empty → count theo empty; nhưng có
      // fallback `else if (answer is! String) count++` khiến List rỗng (không
      // phải String) vẫn đếm. Khoá quirk lại để mọi tinh chỉnh tương lai có
      // test bảo hộ.
      final q = makeQuestion('q1');
      final s = makeBaseState(
        questions: [q],
        answers: {q.id: <String>[]},
      );
      expect(s.answeredCount, 1);
    });

    test('câu hỏi không có entry answers tương ứng không đếm', () {
      final q1 = makeQuestion('q1');
      final q2 = makeQuestion('q2');
      final s = makeBaseState(
        questions: [q1, q2],
        answers: {
          q1.id: {'text': 'có nhập'}
        },
      );
      expect(s.answeredCount, 1);
      expect(s.totalQuestions, 2);
    });
  });

  group('QuestionChoiceState.fromJson', () {
    test('parse content dạng String', () {
      final c = QuestionChoiceState.fromJson({
        'id': 0,
        'content': 'Lựa chọn A',
        'is_correct': true,
      });
      expect(c.id, 0);
      expect(c.content, 'Lựa chọn A');
      expect(c.isCorrect, true);
    });

    test('parse content dạng Map {text:...}', () {
      final c = QuestionChoiceState.fromJson({
        'id': 1,
        'content': {'text': 'Lựa chọn B'},
        'is_correct': false,
      });
      expect(c.id, 1);
      expect(c.content, 'Lựa chọn B');
      expect(c.isCorrect, false);
    });

    test('id String được parse sang int; thiếu id → fallback index', () {
      final c1 = QuestionChoiceState.fromJson({
        'id': '7',
        'content': {'text': 'X'},
      });
      expect(c1.id, 7);

      final c2 = QuestionChoiceState.fromJson(
        {
          'content': {'text': 'Y'},
        },
        index: 3,
      );
      expect(c2.id, 3);
    });

    test('hỗ trợ cả isCorrect và is_correct', () {
      final camel = QuestionChoiceState.fromJson({
        'id': 0,
        'content': 'X',
        'isCorrect': true,
      });
      final snake = QuestionChoiceState.fromJson({
        'id': 0,
        'content': 'X',
        'is_correct': true,
      });
      expect(camel.isCorrect, true);
      expect(snake.isCorrect, true);
    });
  });

  group('QuestionState.fromJson — content', () {
    test('content là String trả về như cũ', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': 'Văn bản câu hỏi',
        'points': 2,
      });
      expect(q.id, 'aq-1');
      expect(q.content, 'Văn bản câu hỏi');
      expect(q.points, 2.0);
    });

    test('content là Map ưu tiên override_text', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': {
          'override_text': 'Đề đã sửa',
          'text': 'Đề gốc',
        },
      });
      expect(q.content, 'Đề đã sửa');
    });

    test('content Map không có override_text fallback về text', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'essay',
        'content': {'text': 'Đề gốc'},
      });
      expect(q.content, 'Đề gốc');
    });
  });

  group('QuestionState.fromJson — choices từ question_choices', () {
    test('parse list question_choices và sắp theo order ban đầu', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': 'X',
        'question_choices': [
          {
            'id': 0,
            'content': {'text': 'A'},
            'is_correct': false,
          },
          {
            'id': 1,
            'content': {'text': 'B'},
            'is_correct': true,
          },
        ],
      });
      expect(q.choices, hasLength(2));
      expect(q.choices[0].content, 'A');
      expect(q.choices[1].content, 'B');
      expect(q.choices[1].isCorrect, true);
    });

    test('shuffled_choices đảo thứ tự choice theo variant', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': 'X',
        'question_choices': [
          {
            'id': 0,
            'content': {'text': 'A'},
            'is_correct': false,
          },
          {
            'id': 1,
            'content': {'text': 'B'},
            'is_correct': true,
          },
          {
            'id': 2,
            'content': {'text': 'C'},
            'is_correct': false,
          },
        ],
        'shuffled_choices': [2, 0, 1],
      });
      expect(q.choices.map((c) => c.content).toList(), ['C', 'A', 'B']);
      expect(q.choices.map((c) => c.id).toList(), [2, 0, 1]);
    });

    test(
        'shuffled_choices.length lệch question_choices.length thì giữ thứ tự gốc',
        () {
      // Tránh "mất choice" do variant lỗi.
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': 'X',
        'question_choices': [
          {
            'id': 0,
            'content': {'text': 'A'},
            'is_correct': true,
          },
          {
            'id': 1,
            'content': {'text': 'B'},
            'is_correct': false,
          },
        ],
        'shuffled_choices': [0], // thiếu 1 → bỏ qua reorder
      });
      expect(q.choices.map((c) => c.content).toList(), ['A', 'B']);
    });
  });

  group('QuestionState.fromJson — choices fallback từ content.options', () {
    test('Khi không có question_choices, lấy từ content.options', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': {
          'override_text': 'Câu hỏi',
          'options': [
            {'text': 'A', 'isCorrect': false},
            {'text': 'B', 'isCorrect': true},
          ],
        },
      });
      expect(q.content, 'Câu hỏi');
      expect(q.choices, hasLength(2));
      expect(q.choices[1].content, 'B');
      expect(q.choices[1].isCorrect, true);
      // ID auto-assign từ index khi options không có id.
      expect(q.choices[0].id, 0);
      expect(q.choices[1].id, 1);
    });
  });

  group('QuestionState.fromJson — các field tuỳ chọn', () {
    test('parse blanks/pairs/distractors/expectedAnswer/aiGradingKeywords/rubric',
        () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'fill_blank',
        'content': 'Điền vào chỗ trống',
        'blanks': [
          {
            'id': 'b1',
            'correct_values': ['Hà Nội'],
          }
        ],
        'pairs': [
          {'left_text': 'L', 'right_text': 'R'}
        ],
        'distractors': [
          {'id': 'd1', 'text': 'Gây nhiễu'}
        ],
        'expected_answer': 'Câu trả lời mẫu',
        'ai_grading_keywords': [
          {'id': 'kw1', 'keyword': 'từ khóa', 'weight': 0.5}
        ],
        'rubric': {
          'criteria': [
            {'id': 'r1', 'description': 'Đầy đủ', 'max_score': 5}
          ]
        },
      });
      expect(q.blanks, isNotNull);
      expect(q.blanks!.first['id'], 'b1');
      expect(q.pairs, isNotNull);
      expect(q.pairs!.first['left_text'], 'L');
      expect(q.distractors, isNotNull);
      expect(q.distractors!.first['text'], 'Gây nhiễu');
      expect(q.expectedAnswer, 'Câu trả lời mẫu');
      expect(q.aiGradingKeywords, isNotNull);
      expect(q.aiGradingKeywords!.first['weight'], 0.5);
      expect(q.rubric, isNotNull);
      expect(q.rubric!['criteria'], isA<List<dynamic>>());
    });

    test('các field tuỳ chọn vắng mặt → null', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'type': 'multiple_choice',
        'content': 'X',
      });
      expect(q.blanks, isNull);
      expect(q.pairs, isNull);
      expect(q.distractors, isNull);
      expect(q.expectedAnswer, isNull);
      expect(q.aiGradingKeywords, isNull);
      expect(q.rubric, isNull);
    });
  });

  group('QuestionState.fromJson — defaults & edge cases', () {
    test('thiếu type → fallback multiple_choice; thiếu points → 1.0', () {
      final q = QuestionState.fromJson({
        'id': 'aq-1',
        'content': 'X',
      });
      expect(q.type, 'multiple_choice');
      expect(q.points, 1.0);
    });

    test('payload lồng dưới key questions (cấu trúc cũ) vẫn parse được', () {
      final q = QuestionState.fromJson({
        'questions': {
          'id': 'aq-1',
          'type': 'true_false',
          'content': 'Đúng hay sai?',
          'points': 1,
        }
      });
      expect(q.id, 'aq-1');
      expect(q.type, 'true_false');
      expect(q.content, 'Đúng hay sai?');
    });
  });

  group('WorkspaceState.isPastDueClosed (lock submit khi quá hạn)', () {
    test('không có dueAt → never closed', () {
      final s = makeBaseState();
      expect(s.isPastDueClosed, isFalse);
    });

    test('allowLate=true → never closed dù quá hạn', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final s = makeBaseState(dueAt: past, allowLate: true);
      expect(s.isPastDueClosed, isFalse);
    });

    test('allowLate=false + dueAt còn → mở (chưa khoá)', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      final s = makeBaseState(dueAt: future, allowLate: false);
      expect(s.isPastDueClosed, isFalse);
    });

    test('allowLate=false + dueAt đã qua → đóng cứng', () {
      final past = DateTime.now().subtract(const Duration(minutes: 10));
      final s = makeBaseState(dueAt: past, allowLate: false);
      expect(s.isPastDueClosed, isTrue);
    });

    test('default allowLate=true (backward compat) khi không truyền', () {
      // Mặc định distribution.allow_late=true → dueAt qua không khoá.
      final past = DateTime.now().subtract(const Duration(minutes: 1));
      final s = WorkspaceState(
        distributionId: 'd',
        assignmentTitle: 't',
        dueAt: past,
        questions: const [],
        answers: const {},
        uploadedFiles: const [],
        submissionStatus: WorkspaceSubmissionStatus.inProgress,
        savingStatus: SavingStatus.idle,
      );
      expect(s.allowLate, isTrue, reason: 'allowLate default = true');
      expect(s.isPastDueClosed, isFalse);
    });
  });

  group('QuestionState.copyWith', () {
    test('giữ nguyên field không truyền + override field được truyền', () {
      final base = QuestionState(
        id: 'q1',
        content: 'A',
        type: 'multiple_choice',
        points: 1,
        choices: const [],
      );
      final next = base.copyWith(content: 'B', points: 2);
      expect(next.id, 'q1');
      expect(next.content, 'B');
      expect(next.points, 2);
      expect(next.type, 'multiple_choice');
    });
  });
}
