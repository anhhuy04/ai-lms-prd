import 'package:ai_mls/data/datasources/submission_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

/// Track 2 — datasource cho "Batch grade by question".
///
/// Lưu ý: [SubmissionDataSource] dùng `SupabaseService.client` (Supabase.instance),
/// chỉ khởi tạo được khi SDK đã boot — nên KHÔNG mock được client trong unit test
/// thuần (theo đúng quy ước repo: xem recommendation_datasource_test.dart). Test
/// hành vi gọi RPC + map kết quả được phủ ở tầng provider (override datasource bằng
/// mocktail) trong test/providers/batch_grade_provider_test.dart.
///
/// Ở đây ta kiểm tra compile-time: 2 method mới tồn tại với đúng chữ ký.
void main() {
  group('SubmissionDataSource — batch grade methods', () {
    late SubmissionDataSource ds;

    setUp(() {
      ds = SubmissionDataSource();
    });

    test('có thể khởi tạo', () {
      expect(ds, isNotNull);
    });

    test('getDistributionAnswersByQuestion có đúng chữ ký', () {
      // Tham chiếu hàm (không gọi để tránh chạm Supabase.instance).
      final Future<List<Map<String, dynamic>>> Function({
        required String distributionId,
        required String assignmentQuestionId,
      }) fn = ds.getDistributionAnswersByQuestion;
      expect(fn, isNotNull);
    });

    test('batchApproveAiScores có đúng chữ ký', () {
      final Future<int> Function({
        required List<String> answerIds,
        required String gradedBy,
      }) fn = ds.batchApproveAiScores;
      expect(fn, isNotNull);
    });
  });
}
