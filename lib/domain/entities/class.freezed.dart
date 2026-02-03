// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Class _$ClassFromJson(Map<String, dynamic> json) {
  return _Class.fromJson(json);
}

/// @nodoc
mixin _$Class {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'school_id')
  String? get schoolId => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get subject => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_year')
  String? get academicYear => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Tên giáo viên hiển thị cho học sinh.
  /// Được map từ alias SQL `teacher_name` trong các query join với bảng profiles.
  @JsonKey(name: 'teacher_name')
  String? get teacherName => throw _privateConstructorUsedError;

  /// Tổng số học sinh trong lớp (đã duyệt, status = approved).
  /// Được map từ alias SQL `student_count` trong các query aggregate.
  @JsonKey(name: 'student_count')
  int? get studentCount => throw _privateConstructorUsedError;

  /// Trạng thái tham gia của học sinh hiện tại trong lớp:
  /// - 'pending': Đang chờ giáo viên duyệt
  /// - 'approved': Đã vào lớp
  /// Field này chỉ có ý nghĩa trong luồng học sinh.
  @JsonKey(name: 'member_status')
  String? get memberStatus => throw _privateConstructorUsedError;

  /// Cài đặt lớp học từ DB (có thể null nếu record cũ/thiếu field).
  /// Dùng fromJson để luôn có default khi DB trả về null/không đúng kiểu.
  @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
  Map<String, dynamic>? get classSettings => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Class to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Class
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassCopyWith<Class> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassCopyWith<$Res> {
  factory $ClassCopyWith(Class value, $Res Function(Class) then) =
      _$ClassCopyWithImpl<$Res, Class>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'teacher_id') String teacherId,
    String name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'student_count') int? studentCount,
    @JsonKey(name: 'member_status') String? memberStatus,
    @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
    Map<String, dynamic>? classSettings,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ClassCopyWithImpl<$Res, $Val extends Class>
    implements $ClassCopyWith<$Res> {
  _$ClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Class
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = freezed,
    Object? teacherId = null,
    Object? name = null,
    Object? subject = freezed,
    Object? academicYear = freezed,
    Object? description = freezed,
    Object? teacherName = freezed,
    Object? studentCount = freezed,
    Object? memberStatus = freezed,
    Object? classSettings = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            schoolId: freezed == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String?,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            subject: freezed == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String?,
            academicYear: freezed == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            teacherName: freezed == teacherName
                ? _value.teacherName
                : teacherName // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentCount: freezed == studentCount
                ? _value.studentCount
                : studentCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            memberStatus: freezed == memberStatus
                ? _value.memberStatus
                : memberStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            classSettings: freezed == classSettings
                ? _value.classSettings
                : classSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassImplCopyWith<$Res> implements $ClassCopyWith<$Res> {
  factory _$$ClassImplCopyWith(
    _$ClassImpl value,
    $Res Function(_$ClassImpl) then,
  ) = __$$ClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'teacher_id') String teacherId,
    String name,
    String? subject,
    @JsonKey(name: 'academic_year') String? academicYear,
    String? description,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'student_count') int? studentCount,
    @JsonKey(name: 'member_status') String? memberStatus,
    @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
    Map<String, dynamic>? classSettings,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ClassImplCopyWithImpl<$Res>
    extends _$ClassCopyWithImpl<$Res, _$ClassImpl>
    implements _$$ClassImplCopyWith<$Res> {
  __$$ClassImplCopyWithImpl(
    _$ClassImpl _value,
    $Res Function(_$ClassImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Class
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = freezed,
    Object? teacherId = null,
    Object? name = null,
    Object? subject = freezed,
    Object? academicYear = freezed,
    Object? description = freezed,
    Object? teacherName = freezed,
    Object? studentCount = freezed,
    Object? memberStatus = freezed,
    Object? classSettings = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ClassImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        schoolId: freezed == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String?,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: freezed == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String?,
        academicYear: freezed == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        teacherName: freezed == teacherName
            ? _value.teacherName
            : teacherName // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentCount: freezed == studentCount
            ? _value.studentCount
            : studentCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        memberStatus: freezed == memberStatus
            ? _value.memberStatus
            : memberStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        classSettings: freezed == classSettings
            ? _value._classSettings
            : classSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassImpl extends _Class {
  const _$ClassImpl({
    required this.id,
    @JsonKey(name: 'school_id') this.schoolId,
    @JsonKey(name: 'teacher_id') required this.teacherId,
    required this.name,
    this.subject,
    @JsonKey(name: 'academic_year') this.academicYear,
    this.description,
    @JsonKey(name: 'teacher_name') this.teacherName,
    @JsonKey(name: 'student_count') this.studentCount,
    @JsonKey(name: 'member_status') this.memberStatus,
    @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
    final Map<String, dynamic>? classSettings,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : _classSettings = classSettings,
       super._();

  factory _$ClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'school_id')
  final String? schoolId;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  final String name;
  @override
  final String? subject;
  @override
  @JsonKey(name: 'academic_year')
  final String? academicYear;
  @override
  final String? description;

  /// Tên giáo viên hiển thị cho học sinh.
  /// Được map từ alias SQL `teacher_name` trong các query join với bảng profiles.
  @override
  @JsonKey(name: 'teacher_name')
  final String? teacherName;

  /// Tổng số học sinh trong lớp (đã duyệt, status = approved).
  /// Được map từ alias SQL `student_count` trong các query aggregate.
  @override
  @JsonKey(name: 'student_count')
  final int? studentCount;

  /// Trạng thái tham gia của học sinh hiện tại trong lớp:
  /// - 'pending': Đang chờ giáo viên duyệt
  /// - 'approved': Đã vào lớp
  /// Field này chỉ có ý nghĩa trong luồng học sinh.
  @override
  @JsonKey(name: 'member_status')
  final String? memberStatus;

  /// Cài đặt lớp học từ DB (có thể null nếu record cũ/thiếu field).
  /// Dùng fromJson để luôn có default khi DB trả về null/không đúng kiểu.
  final Map<String, dynamic>? _classSettings;

  /// Cài đặt lớp học từ DB (có thể null nếu record cũ/thiếu field).
  /// Dùng fromJson để luôn có default khi DB trả về null/không đúng kiểu.
  @override
  @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
  Map<String, dynamic>? get classSettings {
    final value = _classSettings;
    if (value == null) return null;
    if (_classSettings is EqualUnmodifiableMapView) return _classSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Class(id: $id, schoolId: $schoolId, teacherId: $teacherId, name: $name, subject: $subject, academicYear: $academicYear, description: $description, teacherName: $teacherName, studentCount: $studentCount, memberStatus: $memberStatus, classSettings: $classSettings, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.studentCount, studentCount) ||
                other.studentCount == studentCount) &&
            (identical(other.memberStatus, memberStatus) ||
                other.memberStatus == memberStatus) &&
            const DeepCollectionEquality().equals(
              other._classSettings,
              _classSettings,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    schoolId,
    teacherId,
    name,
    subject,
    academicYear,
    description,
    teacherName,
    studentCount,
    memberStatus,
    const DeepCollectionEquality().hash(_classSettings),
    createdAt,
  );

  /// Create a copy of Class
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassImplCopyWith<_$ClassImpl> get copyWith =>
      __$$ClassImplCopyWithImpl<_$ClassImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassImplToJson(this);
  }
}

abstract class _Class extends Class {
  const factory _Class({
    required final String id,
    @JsonKey(name: 'school_id') final String? schoolId,
    @JsonKey(name: 'teacher_id') required final String teacherId,
    required final String name,
    final String? subject,
    @JsonKey(name: 'academic_year') final String? academicYear,
    final String? description,
    @JsonKey(name: 'teacher_name') final String? teacherName,
    @JsonKey(name: 'student_count') final int? studentCount,
    @JsonKey(name: 'member_status') final String? memberStatus,
    @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
    final Map<String, dynamic>? classSettings,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ClassImpl;
  const _Class._() : super._();

  factory _Class.fromJson(Map<String, dynamic> json) = _$ClassImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'school_id')
  String? get schoolId;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  String get name;
  @override
  String? get subject;
  @override
  @JsonKey(name: 'academic_year')
  String? get academicYear;
  @override
  String? get description;

  /// Tên giáo viên hiển thị cho học sinh.
  /// Được map từ alias SQL `teacher_name` trong các query join với bảng profiles.
  @override
  @JsonKey(name: 'teacher_name')
  String? get teacherName;

  /// Tổng số học sinh trong lớp (đã duyệt, status = approved).
  /// Được map từ alias SQL `student_count` trong các query aggregate.
  @override
  @JsonKey(name: 'student_count')
  int? get studentCount;

  /// Trạng thái tham gia của học sinh hiện tại trong lớp:
  /// - 'pending': Đang chờ giáo viên duyệt
  /// - 'approved': Đã vào lớp
  /// Field này chỉ có ý nghĩa trong luồng học sinh.
  @override
  @JsonKey(name: 'member_status')
  String? get memberStatus;

  /// Cài đặt lớp học từ DB (có thể null nếu record cũ/thiếu field).
  /// Dùng fromJson để luôn có default khi DB trả về null/không đúng kiểu.
  @override
  @JsonKey(name: 'class_settings', fromJson: _classSettingsFromJson)
  Map<String, dynamic>? get classSettings;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Class
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassImplCopyWith<_$ClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
