// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassAnalyticsImpl _$$ClassAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$ClassAnalyticsImpl(
  classId: json['class_id'] as String? ?? '',
  className: json['class_name'] as String? ?? '',
  classAverage: (json['class_average'] as num?)?.toDouble() ?? 0.0,
  totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
  totalSubmissions: (json['total_submissions'] as num?)?.toInt() ?? 0,
  submissionRate: (json['submission_rate'] as num?)?.toDouble() ?? 0.0,
  lateSubmissionRate: (json['late_submission_rate'] as num?)?.toDouble() ?? 0.0,
  lateSubmissionCount: (json['late_submission_count'] as num?)?.toInt() ?? 0,
  worstOffender: json['worstOffender'] == null
      ? null
      : WorstOffender.fromJson(json['worstOffender'] as Map<String, dynamic>),
  highestScore: (json['highestScore'] as num?)?.toDouble(),
  lowestScore: (json['lowestScore'] as num?)?.toDouble(),
  distribution:
      (json['distribution'] as List<dynamic>?)
          ?.map((e) => ClassDistribution.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  subjectDistributions:
      (json['subjectDistributions'] as List<dynamic>?)
          ?.map((e) => SubjectDistribution.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  topPerformers:
      (json['top_performers'] as List<dynamic>?)
          ?.map((e) => StudentPerformance.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  bottomPerformers:
      (json['bottom_performers'] as List<dynamic>?)
          ?.map((e) => StudentPerformance.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ClassAnalyticsImplToJson(
  _$ClassAnalyticsImpl instance,
) => <String, dynamic>{
  'class_id': instance.classId,
  'class_name': instance.className,
  'class_average': instance.classAverage,
  'total_students': instance.totalStudents,
  'total_submissions': instance.totalSubmissions,
  'submission_rate': instance.submissionRate,
  'late_submission_rate': instance.lateSubmissionRate,
  'late_submission_count': instance.lateSubmissionCount,
  'worstOffender': instance.worstOffender,
  'highestScore': instance.highestScore,
  'lowestScore': instance.lowestScore,
  'distribution': instance.distribution,
  'subjectDistributions': instance.subjectDistributions,
  'top_performers': instance.topPerformers,
  'bottom_performers': instance.bottomPerformers,
};

_$ClassDistributionImpl _$$ClassDistributionImplFromJson(
  Map<String, dynamic> json,
) => _$ClassDistributionImpl(
  rangeStart: (json['rangeStart'] as num?)?.toInt() ?? 0,
  rangeEnd: (json['rangeEnd'] as num?)?.toInt() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ClassDistributionImplToJson(
  _$ClassDistributionImpl instance,
) => <String, dynamic>{
  'rangeStart': instance.rangeStart,
  'rangeEnd': instance.rangeEnd,
  'count': instance.count,
};

_$StudentPerformanceImpl _$$StudentPerformanceImplFromJson(
  Map<String, dynamic> json,
) => _$StudentPerformanceImpl(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  score: (json['score'] as num).toDouble(),
  submissionCount: (json['submissionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$StudentPerformanceImplToJson(
  _$StudentPerformanceImpl instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'score': instance.score,
  'submissionCount': instance.submissionCount,
};

_$WorstOffenderImpl _$$WorstOffenderImplFromJson(Map<String, dynamic> json) =>
    _$WorstOffenderImpl(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      lateCount: (json['lateCount'] as num).toInt(),
    );

Map<String, dynamic> _$$WorstOffenderImplToJson(_$WorstOffenderImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'lateCount': instance.lateCount,
    };

_$SubjectDistributionImpl _$$SubjectDistributionImplFromJson(
  Map<String, dynamic> json,
) => _$SubjectDistributionImpl(
  subjectName: json['subjectName'] as String,
  below50Count: (json['below50Count'] as num?)?.toInt() ?? 0,
  below60Count: (json['below60Count'] as num?)?.toInt() ?? 0,
  below80Count: (json['below80Count'] as num?)?.toInt() ?? 0,
  above80Count: (json['above80Count'] as num?)?.toInt() ?? 0,
  below50Students:
      (json['below50Students'] as List<dynamic>?)
          ?.map((e) => StudentScoreItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  below60Students:
      (json['below60Students'] as List<dynamic>?)
          ?.map((e) => StudentScoreItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  below80Students:
      (json['below80Students'] as List<dynamic>?)
          ?.map((e) => StudentScoreItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  above80Students:
      (json['above80Students'] as List<dynamic>?)
          ?.map((e) => StudentScoreItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$SubjectDistributionImplToJson(
  _$SubjectDistributionImpl instance,
) => <String, dynamic>{
  'subjectName': instance.subjectName,
  'below50Count': instance.below50Count,
  'below60Count': instance.below60Count,
  'below80Count': instance.below80Count,
  'above80Count': instance.above80Count,
  'below50Students': instance.below50Students,
  'below60Students': instance.below60Students,
  'below80Students': instance.below80Students,
  'above80Students': instance.above80Students,
};

_$StudentScoreItemImpl _$$StudentScoreItemImplFromJson(
  Map<String, dynamic> json,
) => _$StudentScoreItemImpl(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  score: (json['score'] as num).toDouble(),
);

Map<String, dynamic> _$$StudentScoreItemImplToJson(
  _$StudentScoreItemImpl instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'score': instance.score,
};
