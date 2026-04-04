/// Recommendation role enum - who receives the recommendation
enum RecommendationRole {
  student,
  teacher,
}

/// Recommendation type enum - category of recommendation
enum RecommendationType {
  studyTip,
  intervention,
  peerComparison,
  assignmentSuggestion,
  skillGap,
  engagementAlert,
  atRiskWarning,
  improvementOpportunity,
  lateSubmissionAlert,
}

/// Recommendation priority enum
enum RecommendationPriority {
  high,
  medium,
  low,
}

/// Base recommendation entity - used for both student and teacher recommendations
class Recommendation {
  final String id;
  final String userId;
  final RecommendationRole role;
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String? actionLabel;
  final Map<String, dynamic>? actionPayload;
  final bool isRead;
  final bool isDismissed;
  final int unreadCount;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  const Recommendation({
    this.id = '',
    this.userId = '',
    this.role = RecommendationRole.student,
    this.type = RecommendationType.studyTip,
    this.priority = RecommendationPriority.medium,
    this.title = '',
    this.description = '',
    this.actionLabel,
    this.actionPayload,
    this.isRead = false,
    this.isDismissed = false,
    this.unreadCount = 0,
    this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      role: _stringToRole(json['role'] as String?),
      type: _stringToType(json['type'] as String?),
      priority: _stringToPriority(json['priority'] as String?),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      actionLabel: json['action_label'] as String?,
      actionPayload: json['action_payload'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      isDismissed: json['is_dismissed'] as bool? ?? false,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      expiresAt: _parseDateTime(json['expires_at']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': _roleToString(role),
      'type': _typeToString(type),
      'priority': _priorityToString(priority),
      'title': title,
      'description': description,
      'action_label': actionLabel,
      'action_payload': actionPayload,
      'is_read': isRead,
      'is_dismissed': isDismissed,
      'unread_count': unreadCount,
      'created_at': createdAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // --- Convenience getters for UI compatibility ---

  /// Numeric priority value (lower = more urgent) for UI sorting/filtering.
  int get priorityValue {
    switch (priority) {
      case RecommendationPriority.high:
        return 1;
      case RecommendationPriority.medium:
        return 2;
      case RecommendationPriority.low:
        return 3;
    }
  }

  /// Is this recommendation urgent (high priority)?
  bool get isUrgent => priority == RecommendationPriority.high;

  /// Type as lowercase string for UI display.
  String get typeString => _typeToString(type);

  /// Exercises list from metadata (assignment IDs for practice).
  List<String> get exercises {
    if (metadata == null) return [];
    final list = metadata!['exercises'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }

  /// Video URLs from metadata.
  List<String> get videos {
    if (metadata == null) return [];
    final list = metadata!['videos'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }

  /// Document URLs from metadata.
  List<String> get documents {
    if (metadata == null) return [];
    final list = metadata!['documents'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }

  /// Does this recommendation have any learning resources?
  bool get hasResources =>
      exercises.isNotEmpty || videos.isNotEmpty || documents.isNotEmpty;

  Recommendation copyWith({
    String? id,
    String? userId,
    RecommendationRole? role,
    RecommendationType? type,
    RecommendationPriority? priority,
    String? title,
    String? description,
    String? actionLabel,
    Map<String, dynamic>? actionPayload,
    bool? isRead,
    bool? isDismissed,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Recommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      actionLabel: actionLabel ?? this.actionLabel,
      actionPayload: actionPayload ?? this.actionPayload,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
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

  static String _roleToString(RecommendationRole role) {
    switch (role) {
      case RecommendationRole.student:
        return 'student';
      case RecommendationRole.teacher:
        return 'teacher';
    }
  }

  static RecommendationRole _stringToRole(String? value) {
    switch (value) {
      case 'teacher':
        return RecommendationRole.teacher;
      case 'student':
      default:
        return RecommendationRole.student;
    }
  }

  static String _typeToString(RecommendationType type) {
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

  static RecommendationType _stringToType(String? value) {
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

  static String _priorityToString(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return 'high';
      case RecommendationPriority.medium:
        return 'medium';
      case RecommendationPriority.low:
        return 'low';
    }
  }

  static RecommendationPriority _stringToPriority(String? value) {
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
}

/// Extension to get display labels for enums
extension RecommendationRoleExt on RecommendationRole {
  String get label {
    switch (this) {
      case RecommendationRole.student:
        return 'Học sinh';
      case RecommendationRole.teacher:
        return 'Giáo viên';
    }
  }
}

extension RecommendationTypeExt on RecommendationType {
  String get label {
    switch (this) {
      case RecommendationType.studyTip:
        return 'Mẹo học tập';
      case RecommendationType.intervention:
        return 'Can thiệp';
      case RecommendationType.peerComparison:
        return 'So sánh';
      case RecommendationType.assignmentSuggestion:
        return 'Gợi ý bài tập';
      case RecommendationType.skillGap:
        return 'Kỹ năng yếu';
      case RecommendationType.engagementAlert:
        return 'Cảnh báo tham gia';
      case RecommendationType.atRiskWarning:
        return 'Cảnh báo rủi ro';
      case RecommendationType.improvementOpportunity:
        return 'Cơ hội cải thiện';
      case RecommendationType.lateSubmissionAlert:
        return 'Nộp muộn';
    }
  }
}

extension RecommendationPriorityExt on RecommendationPriority {
  String get label {
    switch (this) {
      case RecommendationPriority.high:
        return 'Cao';
      case RecommendationPriority.medium:
        return 'TB';
      case RecommendationPriority.low:
        return 'Thấp';
    }
  }
}

/// Peer comparison data for student analytics
class PeerComparison {
  final double classAverage;
  final double percentile;
  final int rank;
  final int totalStudents;
  /// Điểm trung bình của CHÍNH học sinh hiện tại (không phải điểm của bạn học khác).
  /// Trường này an toàn để gửi lên client vì là dữ liệu cá nhân của người dùng hiện tại.
  /// Điểm trung bình của CHÍNH học sinh hiện tại (không phải điểm của bạn học khác).
  /// Trường này an toàn để gửi lên client vì là dữ liệu cá nhân của người dùng hiện tại.
  final double studentAverage;
  final String? trendDirection;
  final double trendPercentage;

  const PeerComparison({
    this.classAverage = 0.0,
    this.percentile = 0.0,
    this.rank = 0,
    this.totalStudents = 0,
    this.studentAverage = 0.0,
    this.trendDirection,
    this.trendPercentage = 0.0,
  });

  factory PeerComparison.fromJson(Map<String, dynamic> json) {
    return PeerComparison(
      classAverage: (json['class_average'] as num?)?.toDouble() ?? 0.0,
      percentile: (json['percentile'] as num?)?.toDouble() ?? 0.0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      studentAverage: (json['student_average'] as num?)?.toDouble() ?? 0.0,
      trendDirection: json['trend_direction'] as String?,
      trendPercentage: (json['trend_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_average': classAverage,
      'percentile': percentile,
      'rank': rank,
      'total_students': totalStudents,
      'student_average': studentAverage,
      'trend_direction': trendDirection,
      'trend_percentage': trendPercentage,
    };
  }

  PeerComparison copyWith({
    double? classAverage,
    double? percentile,
    int? rank,
    int? totalStudents,
    double? studentAverage,
    String? trendDirection,
    double? trendPercentage,
  }) {
    return PeerComparison(
      classAverage: classAverage ?? this.classAverage,
      percentile: percentile ?? this.percentile,
      rank: rank ?? this.rank,
      totalStudents: totalStudents ?? this.totalStudents,
      studentAverage: studentAverage ?? this.studentAverage,
      trendDirection: trendDirection ?? this.trendDirection,
      trendPercentage: trendPercentage ?? this.trendPercentage,
    );
  }
}
