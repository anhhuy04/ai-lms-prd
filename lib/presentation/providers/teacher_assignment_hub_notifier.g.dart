// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_assignment_hub_notifier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherAssignmentHubStateImpl _$$TeacherAssignmentHubStateImplFromJson(
  Map<String, dynamic> json,
) => _$TeacherAssignmentHubStateImpl(
  statistics: AssignmentStatistics.fromJson(
    json['statistics'] as Map<String, dynamic>,
  ),
  recentActivities: (json['recentActivities'] as List<dynamic>)
      .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$TeacherAssignmentHubStateImplToJson(
  _$TeacherAssignmentHubStateImpl instance,
) => <String, dynamic>{
  'statistics': instance.statistics,
  'recentActivities': instance.recentActivities,
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherAssignmentHubNotifierHash() =>
    r'8449be37e85effb6d5c489876674674456afc9da';

/// Notifier cho Teacher Assignment Hub Screen
///
/// Copied from [TeacherAssignmentHubNotifier].
@ProviderFor(TeacherAssignmentHubNotifier)
final teacherAssignmentHubNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      TeacherAssignmentHubNotifier,
      TeacherAssignmentHubState
    >.internal(
      TeacherAssignmentHubNotifier.new,
      name: r'teacherAssignmentHubNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherAssignmentHubNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeacherAssignmentHubNotifier =
    AutoDisposeAsyncNotifier<TeacherAssignmentHubState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
