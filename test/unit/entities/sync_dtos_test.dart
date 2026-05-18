import 'package:ai_mls/domain/entities/ghost_report.dart';
import 'package:ai_mls/domain/entities/sync_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GhostReport', () {
    test('hasGhosts true when count > 0', () {
      expect(const GhostReport(ghostCount: 5, totalCount: 10).hasGhosts, true);
      expect(const GhostReport(ghostCount: 0, totalCount: 10).hasGhosts, false);
    });

    test('fromJson maps DB jsonb result', () {
      final r = GhostReport.fromJson({'ghost_count': 3, 'total_count': 7});
      expect(r.ghostCount, 3);
      expect(r.totalCount, 7);
    });

    test('fromJson handles null fields as 0', () {
      final r = GhostReport.fromJson({});
      expect(r.ghostCount, 0);
      expect(r.totalCount, 0);
    });
  });

  group('SyncResult', () {
    test('fromJson', () {
      final r = SyncResult.fromJson({'created': 5, 'linked': 2, 'total': 7});
      expect(r.created, 5);
      expect(r.linked, 2);
      expect(r.total, 7);
    });

    test('fromJson handles null fields as 0', () {
      final r = SyncResult.fromJson({});
      expect(r.created, 0);
      expect(r.linked, 0);
      expect(r.total, 0);
    });
  });
}
