// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentAnalyticsImpl _$$StudentAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$StudentAnalyticsImpl(
  basicMetrics: json['basicMetrics'] == null
      ? const BasicEngagementMetrics()
      : BasicEngagementMetrics.fromJson(
          json['basicMetrics'] as Map<String, dynamic>,
        ),
  skillMasteries:
      (json['skillMasteries'] as List<dynamic>?)
          ?.map((e) => SkillMastery.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  gradeTrends:
      (json['gradeTrends'] as List<dynamic>?)
          ?.map((e) => GradeTrend.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  strengthsWeaknesses: json['strengthsWeaknesses'] == null
      ? const StrengthWeaknessAnalysis()
      : StrengthWeaknessAnalysis.fromJson(
          json['strengthsWeaknesses'] as Map<String, dynamic>,
        ),
  classComparison: json['classComparison'] == null
      ? const ClassComparison()
      : ClassComparison.fromJson(
          json['classComparison'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$StudentAnalyticsImplToJson(
  _$StudentAnalyticsImpl instance,
) => <String, dynamic>{
  'basicMetrics': instance.basicMetrics,
  'skillMasteries': instance.skillMasteries,
  'gradeTrends': instance.gradeTrends,
  'strengthsWeaknesses': instance.strengthsWeaknesses,
  'classComparison': instance.classComparison,
};

_$BasicEngagementMetricsImpl _$$BasicEngagementMetricsImplFromJson(
  Map<String, dynamic> json,
) => _$BasicEngagementMetricsImpl(
  avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0,
  onTimeRate: (json['on_time_rate'] as num?)?.toDouble() ?? 0,
  totalTimeMinutes: (json['total_time_minutes'] as num?)?.toInt() ?? 0,
  submissionCount: (json['submission_count'] as num?)?.toInt() ?? 0,
  trendDirection: $enumDecodeNullable(
    _$TrendDirectionEnumMap,
    json['trend_direction'],
  ),
);

Map<String, dynamic> _$$BasicEngagementMetricsImplToJson(
  _$BasicEngagementMetricsImpl instance,
) => <String, dynamic>{
  'avg_score': instance.avgScore,
  'on_time_rate': instance.onTimeRate,
  'total_time_minutes': instance.totalTimeMinutes,
  'submission_count': instance.submissionCount,
  'trend_direction': _$TrendDirectionEnumMap[instance.trendDirection],
};

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.stable: 'stable',
};

_$StrengthWeaknessAnalysisImpl _$$StrengthWeaknessAnalysisImplFromJson(
  Map<String, dynamic> json,
) => _$StrengthWeaknessAnalysisImpl(
  strengths:
      (json['strengths'] as List<dynamic>?)
          ?.map((e) => SkillMastery.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  weaknesses:
      (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => SkillMastery.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$StrengthWeaknessAnalysisImplToJson(
  _$StrengthWeaknessAnalysisImpl instance,
) => <String, dynamic>{
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
};

_$ClassComparisonImpl _$$ClassComparisonImplFromJson(
  Map<String, dynamic> json,
) => _$ClassComparisonImpl(
  classAverage: (json['class_average'] as num?)?.toDouble() ?? 0.0,
  percentile: (json['percentile'] as num?)?.toDouble() ?? 0.0,
  rank: (json['rank'] as num?)?.toInt() ?? 0,
  totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ClassComparisonImplToJson(
  _$ClassComparisonImpl instance,
) => <String, dynamic>{
  'class_average': instance.classAverage,
  'percentile': instance.percentile,
  'rank': instance.rank,
  'total_students': instance.totalStudents,
};
