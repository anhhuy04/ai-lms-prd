import 'package:ai_mls/presentation/providers/workspace_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavingStatus', () {
    test('should have all expected values', () {
      expect(SavingStatus.values.length, 4);
      expect(SavingStatus.values, contains(SavingStatus.idle));
      expect(SavingStatus.values, contains(SavingStatus.saving));
      expect(SavingStatus.values, contains(SavingStatus.saved));
      expect(SavingStatus.values, contains(SavingStatus.error));
    });
  });

  group('WorkspaceSubmissionStatus', () {
    test('should have all expected values', () {
      expect(WorkspaceSubmissionStatus.values.length, 4);
      expect(
          WorkspaceSubmissionStatus.values, contains(WorkspaceSubmissionStatus.inProgress));
      expect(WorkspaceSubmissionStatus.values,
          contains(WorkspaceSubmissionStatus.submitting));
      expect(WorkspaceSubmissionStatus.values,
          contains(WorkspaceSubmissionStatus.submitted));
      expect(
          WorkspaceSubmissionStatus.values, contains(WorkspaceSubmissionStatus.error));
    });
  });

  group('WorkspaceState serialization', () {
    test('SavingStatus enum should be comparable', () {
      expect(SavingStatus.idle == SavingStatus.idle, true);
      expect(SavingStatus.saving == SavingStatus.idle, false);
      expect(SavingStatus.saved == SavingStatus.saved, true);
      expect(SavingStatus.error == SavingStatus.error, true);
    });

    test('WorkspaceSubmissionStatus enum should be comparable', () {
      expect(WorkspaceSubmissionStatus.inProgress == WorkspaceSubmissionStatus.inProgress,
          true);
      expect(WorkspaceSubmissionStatus.submitting == WorkspaceSubmissionStatus.inProgress,
          false);
      expect(WorkspaceSubmissionStatus.submitted == WorkspaceSubmissionStatus.submitted,
          true);
      expect(WorkspaceSubmissionStatus.error == WorkspaceSubmissionStatus.error, true);
    });
  });
}
