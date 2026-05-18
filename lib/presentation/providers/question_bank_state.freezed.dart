// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_bank_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QuestionBankState {
  List<Question> get questions => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  Set<String> get mutatingIds => throw _privateConstructorUsedError;
  QuestionFilter? get activeFilter => throw _privateConstructorUsedError;

  /// Create a copy of QuestionBankState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionBankStateCopyWith<QuestionBankState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionBankStateCopyWith<$Res> {
  factory $QuestionBankStateCopyWith(
    QuestionBankState value,
    $Res Function(QuestionBankState) then,
  ) = _$QuestionBankStateCopyWithImpl<$Res, QuestionBankState>;
  @useResult
  $Res call({
    List<Question> questions,
    bool hasMore,
    Set<String> mutatingIds,
    QuestionFilter? activeFilter,
  });

  $QuestionFilterCopyWith<$Res>? get activeFilter;
}

/// @nodoc
class _$QuestionBankStateCopyWithImpl<$Res, $Val extends QuestionBankState>
    implements $QuestionBankStateCopyWith<$Res> {
  _$QuestionBankStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionBankState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? hasMore = null,
    Object? mutatingIds = null,
    Object? activeFilter = freezed,
  }) {
    return _then(
      _value.copyWith(
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<Question>,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            mutatingIds: null == mutatingIds
                ? _value.mutatingIds
                : mutatingIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            activeFilter: freezed == activeFilter
                ? _value.activeFilter
                : activeFilter // ignore: cast_nullable_to_non_nullable
                      as QuestionFilter?,
          )
          as $Val,
    );
  }

  /// Create a copy of QuestionBankState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuestionFilterCopyWith<$Res>? get activeFilter {
    if (_value.activeFilter == null) {
      return null;
    }

    return $QuestionFilterCopyWith<$Res>(_value.activeFilter!, (value) {
      return _then(_value.copyWith(activeFilter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuestionBankStateImplCopyWith<$Res>
    implements $QuestionBankStateCopyWith<$Res> {
  factory _$$QuestionBankStateImplCopyWith(
    _$QuestionBankStateImpl value,
    $Res Function(_$QuestionBankStateImpl) then,
  ) = __$$QuestionBankStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Question> questions,
    bool hasMore,
    Set<String> mutatingIds,
    QuestionFilter? activeFilter,
  });

  @override
  $QuestionFilterCopyWith<$Res>? get activeFilter;
}

/// @nodoc
class __$$QuestionBankStateImplCopyWithImpl<$Res>
    extends _$QuestionBankStateCopyWithImpl<$Res, _$QuestionBankStateImpl>
    implements _$$QuestionBankStateImplCopyWith<$Res> {
  __$$QuestionBankStateImplCopyWithImpl(
    _$QuestionBankStateImpl _value,
    $Res Function(_$QuestionBankStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionBankState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? hasMore = null,
    Object? mutatingIds = null,
    Object? activeFilter = freezed,
  }) {
    return _then(
      _$QuestionBankStateImpl(
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<Question>,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        mutatingIds: null == mutatingIds
            ? _value._mutatingIds
            : mutatingIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        activeFilter: freezed == activeFilter
            ? _value.activeFilter
            : activeFilter // ignore: cast_nullable_to_non_nullable
                  as QuestionFilter?,
      ),
    );
  }
}

/// @nodoc

class _$QuestionBankStateImpl implements _QuestionBankState {
  const _$QuestionBankStateImpl({
    final List<Question> questions = const <Question>[],
    this.hasMore = false,
    final Set<String> mutatingIds = const <String>{},
    this.activeFilter,
  }) : _questions = questions,
       _mutatingIds = mutatingIds;

  final List<Question> _questions;
  @override
  @JsonKey()
  List<Question> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  @JsonKey()
  final bool hasMore;
  final Set<String> _mutatingIds;
  @override
  @JsonKey()
  Set<String> get mutatingIds {
    if (_mutatingIds is EqualUnmodifiableSetView) return _mutatingIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_mutatingIds);
  }

  @override
  final QuestionFilter? activeFilter;

  @override
  String toString() {
    return 'QuestionBankState(questions: $questions, hasMore: $hasMore, mutatingIds: $mutatingIds, activeFilter: $activeFilter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionBankStateImpl &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            const DeepCollectionEquality().equals(
              other._mutatingIds,
              _mutatingIds,
            ) &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_questions),
    hasMore,
    const DeepCollectionEquality().hash(_mutatingIds),
    activeFilter,
  );

  /// Create a copy of QuestionBankState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionBankStateImplCopyWith<_$QuestionBankStateImpl> get copyWith =>
      __$$QuestionBankStateImplCopyWithImpl<_$QuestionBankStateImpl>(
        this,
        _$identity,
      );
}

abstract class _QuestionBankState implements QuestionBankState {
  const factory _QuestionBankState({
    final List<Question> questions,
    final bool hasMore,
    final Set<String> mutatingIds,
    final QuestionFilter? activeFilter,
  }) = _$QuestionBankStateImpl;

  @override
  List<Question> get questions;
  @override
  bool get hasMore;
  @override
  Set<String> get mutatingIds;
  @override
  QuestionFilter? get activeFilter;

  /// Create a copy of QuestionBankState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionBankStateImplCopyWith<_$QuestionBankStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
