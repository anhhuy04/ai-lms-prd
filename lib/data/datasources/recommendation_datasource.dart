import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:ai_mls/domain/entities/recommendation/recommendation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource for recommendation queries from Supabase
class RecommendationDatasource {
  SupabaseClient get _client => SupabaseService.client;

  /// Query 1 (REC-01): Get recommendations for student
  Future<List<Recommendation>> getStudentRecommendations(
    String studentId, {
    String? classId,
    RecommendationType? type,
    RecommendationPriority? minPriority,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('recommendations')
          .select('*')
          .eq('user_id', studentId)
          .eq('role', 'student')
          .eq('is_dismissed', false);

      if (type != null) {
        query = query.eq('type', _typeToString(type));
      }

      if (minPriority != null) {
        // Priority comparison: high=0, medium=1, low=2
        final minPriorityOrder = _priorityOrder(minPriority);
        query = query.lte('priority_order', minPriorityOrder);
      }

      final result = await query
          .order('priority_order', ascending: true)
          .order('created_at', ascending: false)
          .limit(limit);

      return result.map((row) => _mapToRecommendation(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] getStudentRecommendations error',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Query 2 (REC-02): Get recommendations for teacher
  Future<List<Recommendation>> getTeacherRecommendations(
    String teacherId, {
    String? classId,
    RecommendationType? type,
    RecommendationPriority? minPriority,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('recommendations')
          .select('*')
          .eq('user_id', teacherId)
          .eq('role', 'teacher')
          .eq('is_dismissed', false);

      if (type != null) {
        query = query.eq('type', _typeToString(type));
      }

      if (minPriority != null) {
        final minPriorityOrder = _priorityOrder(minPriority);
        query = query.lte('priority_order', minPriorityOrder);
      }

      final result = await query
          .order('priority_order', ascending: true)
          .order('created_at', ascending: false)
          .limit(limit);

      return result.map((row) => _mapToRecommendation(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] getTeacherRecommendations error',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Query 3 (REC-03): Get peer comparison for student analytics
  Future<PeerComparison> getPeerComparison(
    String studentId,
    String classId,
  ) async {
    try {
      // Call the RPC function
      final result = await _client.rpc('get_class_comparison', params: {
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

  /// Mark a recommendation as read
  Future<bool> markAsRead(String recommendationId) async {
    try {
      await _client
          .from('recommendations')
          .update({'is_read': true})
          .eq('id', recommendationId);
      return true;
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] markAsRead error',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Dismiss a recommendation
  Future<bool> dismissRecommendation(String recommendationId) async {
    try {
      await _client
          .from('recommendations')
          .update({'is_dismissed': true})
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
          .from('recommendations')
          .update({'is_dismissed': true})
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

  /// Get unread recommendation count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _client
          .from('recommendations')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .eq('is_dismissed', false);
      return result.length;
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] getUnreadCount error',
        error: e,
        stackTrace: st,
      );
      return 0;
    }
  }

  /// Create a new recommendation
  Future<String?> createRecommendation(Recommendation recommendation) async {
    try {
      final row = await _client.from('recommendations').insert({
        'user_id': recommendation.userId,
        'role': _roleToString(recommendation.role),
        'type': _typeToString(recommendation.type),
        'priority': _priorityToString(recommendation.priority),
        'priority_order': _priorityOrder(recommendation.priority),
        'title': recommendation.title,
        'description': recommendation.description,
        'action_label': recommendation.actionLabel,
        'action_payload': recommendation.actionPayload,
        'metadata': recommendation.metadata,
        'expires_at': recommendation.expiresAt?.toIso8601String(),
      }).select('id').single();
      return row['id'] as String?;
    } catch (e, st) {
      AppLogger.error(
        '[RecommendationDatasource] createRecommendation error',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ---- Private helpers ----

  Recommendation _mapToRecommendation(Map<String, dynamic> row) {
    return Recommendation(
      id: (row['id'] as String?) ?? '',
      userId: (row['user_id'] as String?) ?? '',
      role: _stringToRole(row['role'] as String?),
      type: _stringToType(row['type'] as String?),
      priority: _stringToPriority(row['priority'] as String?),
      title: (row['title'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      actionLabel: row['action_label'] as String?,
      actionPayload: row['action_payload'] as Map<String, dynamic>?,
      isRead: row['is_read'] as bool? ?? false,
      isDismissed: row['is_dismissed'] as bool? ?? false,
      createdAt: _parseDateTime(row['created_at']),
      expiresAt: _parseDateTime(row['expires_at']),
      metadata: row['metadata'] as Map<String, dynamic>?,
    );
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

  String _roleToString(RecommendationRole role) {
    switch (role) {
      case RecommendationRole.student:
        return 'student';
      case RecommendationRole.teacher:
        return 'teacher';
    }
  }

  RecommendationRole _stringToRole(String? value) {
    switch (value) {
      case 'teacher':
        return RecommendationRole.teacher;
      case 'student':
      default:
        return RecommendationRole.student;
    }
  }

  String _typeToString(RecommendationType type) {
    switch (type) {
      case RecommendationType.studyTip:
        return 'study_tip';
      case RecommendationType.intervention:
        return 'intervention';
      case RecommendationType.peerComparison:
        return 'peer_comparison';
      case RecommendationType.assignmentSuggestion:
        return 'assignment_suggestion';
      case RecommendationType.skillGap:
        return 'skill_gap';
      case RecommendationType.engagementAlert:
        return 'engagement_alert';
      case RecommendationType.atRiskWarning:
        return 'at_risk_warning';
      case RecommendationType.improvementOpportunity:
        return 'improvement_opportunity';
      case RecommendationType.lateSubmissionAlert:
        return 'late_submission_alert';
    }
  }

  RecommendationType _stringToType(String? value) {
    switch (value) {
      case 'intervention':
        return RecommendationType.intervention;
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
      case 'study_tip':
      default:
        return RecommendationType.studyTip;
    }
  }

  String _priorityToString(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return 'high';
      case RecommendationPriority.medium:
        return 'medium';
      case RecommendationPriority.low:
        return 'low';
    }
  }

  RecommendationPriority _stringToPriority(String? value) {
    switch (value) {
      case 'high':
        return RecommendationPriority.high;
      case 'low':
        return RecommendationPriority.low;
      case 'medium':
      default:
        return RecommendationPriority.medium;
    }
  }

  /// Returns numeric order for priority (lower = higher priority)
  int _priorityOrder(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return 0;
      case RecommendationPriority.medium:
        return 1;
      case RecommendationPriority.low:
        return 2;
    }
  }
}
