import 'package:ai_mls/domain/repositories/assignment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assignment_providers.g.dart';

/// Provider cho AssignmentRepository (dùng @riverpod để codegen)
@riverpod
AssignmentRepository assignmentRepository(Ref ref) {
  throw UnimplementedError('Must override assignmentRepositoryProvider');
}

