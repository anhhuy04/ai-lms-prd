// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher_file_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeacherFileModel _$TeacherFileModelFromJson(Map<String, dynamic> json) {
  return _TeacherFileModel.fromJson(json);
}

/// @nodoc
mixin _$TeacherFileModel {
  String get id => throw _privateConstructorUsedError;
  String get filename => throw _privateConstructorUsedError;
  @JsonKey(name: 'storage_path')
  String get storagePath => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_bytes')
  int get sizeBytes => throw _privateConstructorUsedError;
  @JsonKey(name: 'uploaded_by')
  String get uploadedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'processing_status')
  String get processingStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TeacherFileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeacherFileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherFileModelCopyWith<TeacherFileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherFileModelCopyWith<$Res> {
  factory $TeacherFileModelCopyWith(
    TeacherFileModel value,
    $Res Function(TeacherFileModel) then,
  ) = _$TeacherFileModelCopyWithImpl<$Res, TeacherFileModel>;
  @useResult
  $Res call({
    String id,
    String filename,
    @JsonKey(name: 'storage_path') String storagePath,
    String url,
    @JsonKey(name: 'mime_type') String mimeType,
    @JsonKey(name: 'size_bytes') int sizeBytes,
    @JsonKey(name: 'uploaded_by') String uploadedBy,
    @JsonKey(name: 'processing_status') String processingStatus,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$TeacherFileModelCopyWithImpl<$Res, $Val extends TeacherFileModel>
    implements $TeacherFileModelCopyWith<$Res> {
  _$TeacherFileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeacherFileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filename = null,
    Object? storagePath = null,
    Object? url = null,
    Object? mimeType = null,
    Object? sizeBytes = null,
    Object? uploadedBy = null,
    Object? processingStatus = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            filename: null == filename
                ? _value.filename
                : filename // ignore: cast_nullable_to_non_nullable
                      as String,
            storagePath: null == storagePath
                ? _value.storagePath
                : storagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeType: null == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String,
            sizeBytes: null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            uploadedBy: null == uploadedBy
                ? _value.uploadedBy
                : uploadedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            processingStatus: null == processingStatus
                ? _value.processingStatus
                : processingStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeacherFileModelImplCopyWith<$Res>
    implements $TeacherFileModelCopyWith<$Res> {
  factory _$$TeacherFileModelImplCopyWith(
    _$TeacherFileModelImpl value,
    $Res Function(_$TeacherFileModelImpl) then,
  ) = __$$TeacherFileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String filename,
    @JsonKey(name: 'storage_path') String storagePath,
    String url,
    @JsonKey(name: 'mime_type') String mimeType,
    @JsonKey(name: 'size_bytes') int sizeBytes,
    @JsonKey(name: 'uploaded_by') String uploadedBy,
    @JsonKey(name: 'processing_status') String processingStatus,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$TeacherFileModelImplCopyWithImpl<$Res>
    extends _$TeacherFileModelCopyWithImpl<$Res, _$TeacherFileModelImpl>
    implements _$$TeacherFileModelImplCopyWith<$Res> {
  __$$TeacherFileModelImplCopyWithImpl(
    _$TeacherFileModelImpl _value,
    $Res Function(_$TeacherFileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeacherFileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filename = null,
    Object? storagePath = null,
    Object? url = null,
    Object? mimeType = null,
    Object? sizeBytes = null,
    Object? uploadedBy = null,
    Object? processingStatus = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TeacherFileModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        filename: null == filename
            ? _value.filename
            : filename // ignore: cast_nullable_to_non_nullable
                  as String,
        storagePath: null == storagePath
            ? _value.storagePath
            : storagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeType: null == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String,
        sizeBytes: null == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        uploadedBy: null == uploadedBy
            ? _value.uploadedBy
            : uploadedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        processingStatus: null == processingStatus
            ? _value.processingStatus
            : processingStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeacherFileModelImpl implements _TeacherFileModel {
  const _$TeacherFileModelImpl({
    required this.id,
    required this.filename,
    @JsonKey(name: 'storage_path') required this.storagePath,
    required this.url,
    @JsonKey(name: 'mime_type') required this.mimeType,
    @JsonKey(name: 'size_bytes') required this.sizeBytes,
    @JsonKey(name: 'uploaded_by') required this.uploadedBy,
    @JsonKey(name: 'processing_status') this.processingStatus = 'queued',
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$TeacherFileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherFileModelImplFromJson(json);

  @override
  final String id;
  @override
  final String filename;
  @override
  @JsonKey(name: 'storage_path')
  final String storagePath;
  @override
  final String url;
  @override
  @JsonKey(name: 'mime_type')
  final String mimeType;
  @override
  @JsonKey(name: 'size_bytes')
  final int sizeBytes;
  @override
  @JsonKey(name: 'uploaded_by')
  final String uploadedBy;
  @override
  @JsonKey(name: 'processing_status')
  final String processingStatus;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TeacherFileModel(id: $id, filename: $filename, storagePath: $storagePath, url: $url, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedBy: $uploadedBy, processingStatus: $processingStatus, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherFileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.processingStatus, processingStatus) ||
                other.processingStatus == processingStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    filename,
    storagePath,
    url,
    mimeType,
    sizeBytes,
    uploadedBy,
    processingStatus,
    createdAt,
  );

  /// Create a copy of TeacherFileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherFileModelImplCopyWith<_$TeacherFileModelImpl> get copyWith =>
      __$$TeacherFileModelImplCopyWithImpl<_$TeacherFileModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherFileModelImplToJson(this);
  }
}

abstract class _TeacherFileModel implements TeacherFileModel {
  const factory _TeacherFileModel({
    required final String id,
    required final String filename,
    @JsonKey(name: 'storage_path') required final String storagePath,
    required final String url,
    @JsonKey(name: 'mime_type') required final String mimeType,
    @JsonKey(name: 'size_bytes') required final int sizeBytes,
    @JsonKey(name: 'uploaded_by') required final String uploadedBy,
    @JsonKey(name: 'processing_status') final String processingStatus,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$TeacherFileModelImpl;

  factory _TeacherFileModel.fromJson(Map<String, dynamic> json) =
      _$TeacherFileModelImpl.fromJson;

  @override
  String get id;
  @override
  String get filename;
  @override
  @JsonKey(name: 'storage_path')
  String get storagePath;
  @override
  String get url;
  @override
  @JsonKey(name: 'mime_type')
  String get mimeType;
  @override
  @JsonKey(name: 'size_bytes')
  int get sizeBytes;
  @override
  @JsonKey(name: 'uploaded_by')
  String get uploadedBy;
  @override
  @JsonKey(name: 'processing_status')
  String get processingStatus;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of TeacherFileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherFileModelImplCopyWith<_$TeacherFileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
