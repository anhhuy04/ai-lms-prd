// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QuestionFilter {
  String get authorId => throw _privateConstructorUsedError;
  bool get includeGlobal => throw _privateConstructorUsedError;
  bool get includeDeleted => throw _privateConstructorUsedError;
  QuestionType? get type => throw _privateConstructorUsedError;
  int? get difficulty => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<String>? get objectiveIds => throw _privateConstructorUsedError;
  QuestionSource? get sourceFilter => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;
  QuestionSortKey get sortBy => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;

  /// Create a copy of QuestionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionFilterCopyWith<QuestionFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionFilterCopyWith<$Res> {
  factory $QuestionFilterCopyWith(
    QuestionFilter value,
    $Res Function(QuestionFilter) then,
  ) = _$QuestionFilterCopyWithImpl<$Res, QuestionFilter>;
  @useResult
  $Res call({
    String authorId,
    bool includeGlobal,
    bool includeDeleted,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    List<String>? objectiveIds,
    QuestionSource? sourceFilter,
    String? searchQuery,
    QuestionSortKey sortBy,
    int page,
    int pageSize,
  });
}

/// @nodoc
class _$QuestionFilterCopyWithImpl<$Res, $Val extends QuestionFilter>
    implements $QuestionFilterCopyWith<$Res> {
  _$QuestionFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorId = null,
    Object? includeGlobal = null,
    Object? includeDeleted = null,
    Object? type = freezed,
    Object? difficulty = freezed,
    Object? tags = freezed,
    Object? objectiveIds = freezed,
    Object? sourceFilter = freezed,
    Object? searchQuery = freezed,
    Object? sortBy = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(
      _value.copyWith(
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            includeGlobal: null == includeGlobal
                ? _value.includeGlobal
                : includeGlobal // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeDeleted: null == includeDeleted
                ? _value.includeDeleted
                : includeDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as QuestionType?,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            objectiveIds: freezed == objectiveIds
                ? _value.objectiveIds
                : objectiveIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            sourceFilter: freezed == sourceFilter
                ? _value.sourceFilter
                : sourceFilter // ignore: cast_nullable_to_non_nullable
                      as QuestionSource?,
            searchQuery: freezed == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as QuestionSortKey,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionFilterImplCopyWith<$Res>
    implements $QuestionFilterCopyWith<$Res> {
  factory _$$QuestionFilterImplCopyWith(
    _$QuestionFilterImpl value,
    $Res Function(_$QuestionFilterImpl) then,
  ) = __$$QuestionFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String authorId,
    bool includeGlobal,
    bool includeDeleted,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    List<String>? objectiveIds,
    QuestionSource? sourceFilter,
    String? searchQuery,
    QuestionSortKey sortBy,
    int page,
    int pageSize,
  });
}

/// @nodoc
class __$$QuestionFilterImplCopyWithImpl<$Res>
    extends _$QuestionFilterCopyWithImpl<$Res, _$QuestionFilterImpl>
    implements _$$QuestionFilterImplCopyWith<$Res> {
  __$$QuestionFilterImplCopyWithImpl(
    _$QuestionFilterImpl _value,
    $Res Function(_$QuestionFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorId = null,
    Object? includeGlobal = null,
    Object? includeDeleted = null,
    Object? type = freezed,
    Object? difficulty = freezed,
    Object? tags = freezed,
    Object? objectiveIds = freezed,
    Object? sourceFilter = freezed,
    Object? searchQuery = freezed,
    Object? sortBy = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(
      _$QuestionFilterImpl(
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        includeGlobal: null == includeGlobal
            ? _value.includeGlobal
            : includeGlobal // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeDeleted: null == includeDeleted
            ? _value.includeDeleted
            : includeDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as QuestionType?,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        objectiveIds: freezed == objectiveIds
            ? _value._objectiveIds
            : objectiveIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        sourceFilter: freezed == sourceFilter
            ? _value.sourceFilter
            : sourceFilter // ignore: cast_nullable_to_non_nullable
                  as QuestionSource?,
        searchQuery: freezed == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as QuestionSortKey,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$QuestionFilterImpl implements _QuestionFilter {
  const _$QuestionFilterImpl({
    required this.authorId,
    this.includeGlobal = true,
    this.includeDeleted = false,
    this.type,
    this.difficulty,
    final List<String>? tags,
    final List<String>? objectiveIds,
    this.sourceFilter,
    this.searchQuery,
    this.sortBy = QuestionSortKey.recentlyCreated,
    this.page = 0,
    this.pageSize = 20,
  }) : _tags = tags,
       _objectiveIds = objectiveIds;

  @override
  final String authorId;
  @override
  @JsonKey()
  final bool includeGlobal;
  @override
  @JsonKey()
  final bool includeDeleted;
  @override
  final QuestionType? type;
  @override
  final int? difficulty;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _objectiveIds;
  @override
  List<String>? get objectiveIds {
    final value = _objectiveIds;
    if (value == null) return null;
    if (_objectiveIds is EqualUnmodifiableListView) return _objectiveIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final QuestionSource? sourceFilter;
  @override
  final String? searchQuery;
  @override
  @JsonKey()
  final QuestionSortKey sortBy;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pageSize;

  @override
  String toString() {
    return 'QuestionFilter(authorId: $authorId, includeGlobal: $includeGlobal, includeDeleted: $includeDeleted, type: $type, difficulty: $difficulty, tags: $tags, objectiveIds: $objectiveIds, sourceFilter: $sourceFilter, searchQuery: $searchQuery, sortBy: $sortBy, page: $page, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionFilterImpl &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.includeGlobal, includeGlobal) ||
                other.includeGlobal == includeGlobal) &&
            (identical(other.includeDeleted, includeDeleted) ||
                other.includeDeleted == includeDeleted) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._objectiveIds,
              _objectiveIds,
            ) &&
            (identical(other.sourceFilter, sourceFilter) ||
                other.sourceFilter == sourceFilter) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    authorId,
    includeGlobal,
    includeDeleted,
    type,
    difficulty,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_objectiveIds),
    sourceFilter,
    searchQuery,
    sortBy,
    page,
    pageSize,
  );

  /// Create a copy of QuestionFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionFilterImplCopyWith<_$QuestionFilterImpl> get copyWith =>
      __$$QuestionFilterImplCopyWithImpl<_$QuestionFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _QuestionFilter implements QuestionFilter {
  const factory _QuestionFilter({
    required final String authorId,
    final bool includeGlobal,
    final bool includeDeleted,
    final QuestionType? type,
    final int? difficulty,
    final List<String>? tags,
    final List<String>? objectiveIds,
    final QuestionSource? sourceFilter,
    final String? searchQuery,
    final QuestionSortKey sortBy,
    final int page,
    final int pageSize,
  }) = _$QuestionFilterImpl;

  @override
  String get authorId;
  @override
  bool get includeGlobal;
  @override
  bool get includeDeleted;
  @override
  QuestionType? get type;
  @override
  int? get difficulty;
  @override
  List<String>? get tags;
  @override
  List<String>? get objectiveIds;
  @override
  QuestionSource? get sourceFilter;
  @override
  String? get searchQuery;
  @override
  QuestionSortKey get sortBy;
  @override
  int get page;
  @override
  int get pageSize;

  /// Create a copy of QuestionFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionFilterImplCopyWith<_$QuestionFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
