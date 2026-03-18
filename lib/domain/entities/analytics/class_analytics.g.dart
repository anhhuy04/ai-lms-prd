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
  distribution:
      (json['distribution'] as List<dynamic>?)
          ?.map((e) => ClassDistribution.fromJson(e as Map<String, dynamic>))
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
  'distribution': instance.distribution,
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
