import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/question.dart';

part 'question_vm.freezed.dart';

@freezed
class QuestionVM with _$QuestionVM {
  const factory QuestionVM({
    required Question question,
    required bool isOwn,
    required bool canEdit,
    required bool canDelete,
    required bool canSetGlobal,
  }) = _QuestionVM;
}

extension QuestionVMMapper on Question {
  QuestionVM toVM({
    required String currentUserId,
    required bool isAdmin,
  }) => QuestionVM(
    question: this,
    isOwn: authorId == currentUserId,
    canEdit: authorId == currentUserId || isAdmin,
    canDelete: authorId == currentUserId || isAdmin,
    canSetGlobal: isAdmin,
  );
}
