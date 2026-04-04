import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/recommendation/recommendation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource for recommendation queries from Supabase.
/// Uses the ai_recommendations table with schema:
/// - teacher_id / student_id / class_id / type / priority (1-5)
/// - title / description / resources (jsonb) / dismissed
class RecommendationDatasource {
  SupabaseClient get _client => SupabaseService.client;

  /// Query (REC-01): Get recommendations for teacher (interventions)
  Future<List<Recommendation>> getTeacherRecommendations(
    String teacherId, {
    String? classId,
    int limit = 50,
  }) async {
    try {
      var query = _client
          .from('ai_recommendations')
          .select('*')
          .eq('teacher_id', teacherId)
          .eq('dismissed', false);

      if (classId != null) {
        query = query.eq('class_id', classId);
      }

      final result = await query
          .order('priority', ascending: true)
          .order('created_at', ascending: false)
          .limit(limit);

      return result.map((row) => _mapRowToRecommendation(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] getTeacherRecommendations error',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Query (REC-02): Get recommendations for student
  Future<List<Recommendation>> getStudentRecommendations(
    String studentId, {
    String? classId,
    int limit = 50,
  }) async {
    try {
      var query = _client
          .from('ai_recommendations')
          .select('*')
          .eq('student_id', studentId)
          .eq('dismissed', false);

      if (classId != null) {
        query = query.eq('class_id', classId);
      }

      final result = await query
          .order('priority', ascending: true)
          .order('created_at', ascending: false)
          .limit(limit);

      return result.map((row) => _mapRowToRecommendation(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] getStudentRecommendations error',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Query (REC-03): Get peer comparison for student analytics
  Future<PeerComparison> getPeerComparison(
    String studentId,
    String classId,
  ) async {
    try {
      final result = await _client.rpc('get_student_peer_comparison', params: {
        'p_student_id': studentId,
        'p_class_id': classId,
      }).maybeSingle();

      if (result == null) {
        return const PeerComparison();
      }

      return PeerComparison(
        classAverage: (result['class_average'] as num?)?.toDouble() ?? 0.0,
        percentile: (result['percentile'] as num?)?.toDouble() ?? 0.0,
        rank: (result['rank'] as num?)?.toInt() ?? 0,
        totalStudents: (result['total_students'] as num?)?.toInt() ?? 0,
        studentAverage: (result['student_average'] as num?)?.toDouble() ?? 0.0,
        trendDirection: result['trend_direction'] as String?,
        trendPercentage: (result['trend_percentage'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] getPeerComparison error',
        error: e,
        stackTrace: st,
      );
      return const PeerComparison();
    }
  }

  /// Dismiss a recommendation (teacher or student)
  Future<bool> dismissRecommendation(String recommendationId) async {
    try {
      await _client
          .from('ai_recommendations')
          .update({'dismissed': true})
          .eq('id', recommendationId);
      return true;
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] dismissRecommendation error',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Bulk dismiss multiple recommendations
  Future<bool> bulkDismiss(List<String> ids) async {
    if (ids.isEmpty) return true;
    try {
      await _client
          .from('ai_recommendations')
          .update({'dismissed': true})
          .inFilter('id', ids);
      return true;
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] bulkDismiss error',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  // ---- Private helpers ----

  /// Map a database row to Recommendation entity.
  /// Maps ai_recommendations schema to the Recommendation model.
  Recommendation _mapRowToRecommendation(Map<String, dynamic> row) {
    final studentId = row['student_id'] as String?;
    final teacherId = row['teacher_id'] as String?;
    final type = row['type'] as String? ?? 'individual';
    final priority = (row['priority'] as num?)?.toInt() ?? 3;

    return Recommendation(
      id: (row['id'] as String?) ?? '',
      userId: studentId ?? teacherId ?? '',
      role: studentId != null && studentId.isNotEmpty
          ? RecommendationRole.student
          : RecommendationRole.teacher,
      type: _typeStringToEnum(type),
      priority: _priorityIntToEnum(priority),
      title: (row['title'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      isDismissed: row['dismissed'] as bool? ?? false,
      createdAt: _parseDateTime(row['created_at']),
      metadata: _parseResources(row['resources']),
    );
  }

  RecommendationType _typeStringToEnum(String type) {
    switch (type) {
      case 'intervention':
        return RecommendationType.intervention;
      case 'study_tip':
        return RecommendationType.studyTip;
      case 'peer_comparison':
        return RecommendationType.peerComparison;
      case 'assignment_suggestion':
        return RecommendationType.assignmentSuggestion;
      case 'skill_gap':
        return RecommendationType.skillGap;
      case 'engagement_alert':
        return RecommendationType.engagementAlert;
      case 'at_risk_warning':
        return RecommendationType.atRiskWarning;
      case 'improvement_opportunity':
        return RecommendationType.improvementOpportunity;
      case 'late_submission_alert':
        return RecommendationType.lateSubmissionAlert;
      default:
        return RecommendationType.studyTip;
    }
  }

  /// Convert DB priority (1-5) to enum (high=1, medium=2, low=3)
  RecommendationPriority _priorityIntToEnum(int priority) {
    if (priority <= 2) return RecommendationPriority.high;
    if (priority <= 3) return RecommendationPriority.medium;
    return RecommendationPriority.low;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parse resources JSONB {exercises, videos, documents} into metadata map.
  Map<String, dynamic>? _parseResources(dynamic resources) {
    if (resources == null) return null;
    if (resources is Map<String, dynamic>) return resources;
    if (resources is Map) return Map<String, dynamic>.from(resources);
    return null;
  }
}
