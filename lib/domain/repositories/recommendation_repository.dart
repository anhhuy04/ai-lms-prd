import 'package:ai_mls/domain/entities/recommendation/recommendation.dart';

/// Repository interface for recommendation operations
abstract class RecommendationRepository {
  /// Get recommendations for a user
  Future<List<Recommendation>> getRecommendations({
    required String userId,
    required String role,
    String? classId,
    RecommendationType? type,
    RecommendationPriority? minPriority,
    int limit = 20,
  });

  /// Mark a recommendation as read
  Future<bool> markAsRead(String recommendationId);

  /// Dismiss a recommendation
  Future<bool> dismissRecommendation(String recommendationId);

  /// Bulk dismiss multiple recommendations
  Future<bool> bulkDismiss(List<String> ids);

  /// Get unread recommendation count
  Future<int> getUnreadCount(String userId);

  /// Create a new recommendation
  Future<String?> createRecommendation(Recommendation recommendation);

  /// Get peer comparison data for a student in a class
  Future<PeerComparison> getPeerComparison(String studentId, String classId);
}
