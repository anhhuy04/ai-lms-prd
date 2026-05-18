import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/view_models/question_vm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Question.toVM', () {
    const q = Question(
      id: 'q1',
      authorId: 'user1',
      type: QuestionType.multipleChoice,
      content: {'text': 'Q'},
    );

    test('own question + non-admin: canEdit/canDelete true, canSetGlobal false', () {
      final vm = q.toVM(currentUserId: 'user1', isAdmin: false);
      expect(vm.isOwn, true);
      expect(vm.canEdit, true);
      expect(vm.canDelete, true);
      expect(vm.canSetGlobal, false);
    });

    test('not own + admin: canEdit/canDelete/canSetGlobal true', () {
      final vm = q.toVM(currentUserId: 'user2', isAdmin: true);
      expect(vm.isOwn, false);
      expect(vm.canEdit, true);
      expect(vm.canDelete, true);
      expect(vm.canSetGlobal, true);
    });

    test('not own + non-admin: all permissions false', () {
      final vm = q.toVM(currentUserId: 'user2', isAdmin: false);
      expect(vm.isOwn, false);
      expect(vm.canEdit, false);
      expect(vm.canDelete, false);
      expect(vm.canSetGlobal, false);
    });
  });
}
