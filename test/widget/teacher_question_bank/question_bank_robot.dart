import 'dart:async';

import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/profile.dart';
import 'package:ai_mls/domain/entities/question.dart';
import 'package:ai_mls/domain/entities/question_filter.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/domain/repositories/question_repository.dart';
import 'package:ai_mls/presentation/providers/auth_notifier.dart';
import 'package:mocktail/mocktail.dart';

/// Mock cho QuestionRepository.
class MockQuestionRepository extends Mock implements QuestionRepository {}

class _FakeQuestionFilter extends Fake implements QuestionFilter {}

class _FakeCreateQuestionParams extends Fake implements CreateQuestionParams {}

/// Đăng ký fallback values cho các entity dùng làm matcher `any()`.
/// Gọi 1 lần trong `setUpAll`.
void registerFallbacks() {
  registerFallbackValue(_FakeQuestionFilter());
  registerFallbackValue(_FakeCreateQuestionParams());
}

/// Tạo Question giả cho test — chỉ điền các field BẮT BUỘC.
/// `content['text']` được Card/Picker dùng để extract preview.
Question makeQuestion({
  String id = 'q1',
  String authorId = 'user1',
  QuestionType type = QuestionType.multipleChoice,
  String text = 'Sample Q',
  int? difficulty,
  bool isGlobal = false,
  List<String> tags = const [],
}) =>
    Question(
      id: id,
      authorId: authorId,
      type: type,
      content: {'text': text},
      difficulty: difficulty,
      isGlobal: isGlobal,
      tags: tags,
    );

/// Profile giả cho `currentUserProvider` override.
Profile makeProfile({
  String id = 'user1',
  String role = 'teacher',
  String? fullName = 'Test User',
}) =>
    Profile(
      id: id,
      role: role,
      fullName: fullName,
      updatedAt: DateTime(2026, 1, 1),
    );

/// FakeAuthNotifier — subclass AuthNotifier để skip side-effects trong test,
/// chỉ trả về Profile được inject.
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._profile);
  final Profile? _profile;

  @override
  FutureOr<Profile?> build() => _profile;
}
