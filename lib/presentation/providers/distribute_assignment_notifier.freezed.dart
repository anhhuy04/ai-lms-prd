// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'distribute_assignment_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DistributeAssignmentState {
  // Dữ liệu bài tập (optional – nếu được truyền vào từ hub/list)
  Assignment? get assignment =>
      throw _privateConstructorUsedError; // Danh sách bài tập được chọn (hỗ trợ phân phối nhiều bài cùng lúc)
  List<Assignment> get selectedAssignments =>
      throw _privateConstructorUsedError; // --- Đối tượng nhận bài (Tree Selection) ---
  RecipientSelectionResult? get recipientSelection =>
      throw _privateConstructorUsedError; // --- Thời gian ---
  DateTime? get dueDate =>
      throw _privateConstructorUsedError; // Ngày giờ nộp bài
  DateTime? get availableFrom =>
      throw _privateConstructorUsedError; // Ngày giờ mở bài (null = ngay lập tức)
  DateTime? get availableUntil =>
      throw _privateConstructorUsedError; // Ngày giờ đóng bài (null = không giới hạn)
  int? get timeLimitMinutes =>
      throw _privateConstructorUsedError; // Giới hạn thời gian làm bài (phút)
  // --- Cài đặt nâng cao ---
  bool get allowLate => throw _privateConstructorUsedError; // Cho phép nộp muộn
  int get latePenaltyPercent =>
      throw _privateConstructorUsedError; // Phần trăm trừ điểm mỗi ngày trễ
  bool get showScoreImmediately =>
      throw _privateConstructorUsedError; // Hiển thị điểm ngay sau khi nộp
  bool get sendNotification =>
      throw _privateConstructorUsedError; // Gửi thông báo cho học sinh
  bool get shuffleQuestions =>
      throw _privateConstructorUsedError; // Đảo câu hỏi
  bool get shuffleAnswers => throw _privateConstructorUsedError; // Đảo đáp án
  // --- UI State ---
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of DistributeAssignmentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DistributeAssignmentStateCopyWith<DistributeAssignmentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistributeAssignmentStateCopyWith<$Res> {
  factory $DistributeAssignmentStateCopyWith(
    DistributeAssignmentState value,
    $Res Function(DistributeAssignmentState) then,
  ) = _$DistributeAssignmentStateCopyWithImpl<$Res, DistributeAssignmentState>;
  @useResult
  $Res call({
    Assignment? assignment,
    List<Assignment> selectedAssignments,
    RecipientSelectionResult? recipientSelection,
    DateTime? dueDate,
    DateTime? availableFrom,
    DateTime? availableUntil,
    int? timeLimitMinutes,
    bool allowLate,
    int latePenaltyPercent,
    bool showScoreImmediately,
    bool sendNotification,
    bool shuffleQuestions,
    bool shuffleAnswers,
    bool isLoading,
    bool isSuccess,
    String? errorMessage,
  });

  $AssignmentCopyWith<$Res>? get assignment;
}

/// @nodoc
class _$DistributeAssignmentStateCopyWithImpl<
  $Res,
  $Val extends DistributeAssignmentState
>
    implements $DistributeAssignmentStateCopyWith<$Res> {
  _$DistributeAssignmentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DistributeAssignmentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignment = freezed,
    Object? selectedAssignments = null,
    Object? recipientSelection = freezed,
    Object? dueDate = freezed,
    Object? availableFrom = freezed,
    Object? availableUntil = freezed,
    Object? timeLimitMinutes = freezed,
    Object? allowLate = null,
    Object? latePenaltyPercent = null,
    Object? showScoreImmediately = null,
    Object? sendNotification = null,
    Object? shuffleQuestions = null,
    Object? shuffleAnswers = null,
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            assignment: freezed == assignment
                ? _value.assignment
                : assignment // ignore: cast_nullable_to_non_nullable
                      as Assignment?,
            selectedAssignments: null == selectedAssignments
                ? _value.selectedAssignments
                : selectedAssignments // ignore: cast_nullable_to_non_nullable
                      as List<Assignment>,
            recipientSelection: freezed == recipientSelection
                ? _value.recipientSelection
                : recipientSelection // ignore: cast_nullable_to_non_nullable
                      as RecipientSelectionResult?,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            availableFrom: freezed == availableFrom
                ? _value.availableFrom
                : availableFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            availableUntil: freezed == availableUntil
                ? _value.availableUntil
                : availableUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            timeLimitMinutes: freezed == timeLimitMinutes
                ? _value.timeLimitMinutes
                : timeLimitMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            allowLate: null == allowLate
                ? _value.allowLate
                : allowLate // ignore: cast_nullable_to_non_nullable
                      as bool,
            latePenaltyPercent: null == latePenaltyPercent
                ? _value.latePenaltyPercent
                : latePenaltyPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            showScoreImmediately: null == showScoreImmediately
                ? _value.showScoreImmediately
                : showScoreImmediately // ignore: cast_nullable_to_non_nullable
                      as bool,
            sendNotification: null == sendNotification
                ? _value.sendNotification
                : sendNotification // ignore: cast_nullable_to_non_nullable
                      as bool,
            shuffleQuestions: null == shuffleQuestions
                ? _value.shuffleQuestions
                : shuffleQuestions // ignore: cast_nullable_to_non_nullable
                      as bool,
            shuffleAnswers: null == shuffleAnswers
                ? _value.shuffleAnswers
                : shuffleAnswers // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuccess: null == isSuccess
                ? _value.isSuccess
                : isSuccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DistributeAssignmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssignmentCopyWith<$Res>? get assignment {
    if (_value.assignment == null) {
      return null;
    }

    return $AssignmentCopyWith<$Res>(_value.assignment!, (value) {
      return _then(_value.copyWith(assignment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DistributeAssignmentStateImplCopyWith<$Res>
    implements $DistributeAssignmentStateCopyWith<$Res> {
  factory _$$DistributeAssignmentStateImplCopyWith(
    _$DistributeAssignmentStateImpl value,
    $Res Function(_$DistributeAssignmentStateImpl) then,
  ) = __$$DistributeAssignmentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Assignment? assignment,
    List<Assignment> selectedAssignments,
    RecipientSelectionResult? recipientSelection,
    DateTime? dueDate,
    DateTime? availableFrom,
    DateTime? availableUntil,
    int? timeLimitMinutes,
    bool allowLate,
    int latePenaltyPercent,
    bool showScoreImmediately,
    bool sendNotification,
    bool shuffleQuestions,
    bool shuffleAnswers,
    bool isLoading,
    bool isSuccess,
    String? errorMessage,
  });

  @override
  $AssignmentCopyWith<$Res>? get assignment;
}

/// @nodoc
class __$$DistributeAssignmentStateImplCopyWithImpl<$Res>
    extends
        _$DistributeAssignmentStateCopyWithImpl<
          $Res,
          _$DistributeAssignmentStateImpl
        >
    implements _$$DistributeAssignmentStateImplCopyWith<$Res> {
  __$$DistributeAssignmentStateImplCopyWithImpl(
    _$DistributeAssignmentStateImpl _value,
    $Res Function(_$DistributeAssignmentStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DistributeAssignmentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignment = freezed,
    Object? selectedAssignments = null,
    Object? recipientSelection = freezed,
    Object? dueDate = freezed,
    Object? availableFrom = freezed,
    Object? availableUntil = freezed,
    Object? timeLimitMinutes = freezed,
    Object? allowLate = null,
    Object? latePenaltyPercent = null,
    Object? showScoreImmediately = null,
    Object? sendNotification = null,
    Object? shuffleQuestions = null,
    Object? shuffleAnswers = null,
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$DistributeAssignmentStateImpl(
        assignment: freezed == assignment
            ? _value.assignment
            : assignment // ignore: cast_nullable_to_non_nullable
                  as Assignment?,
        selectedAssignments: null == selectedAssignments
            ? _value._selectedAssignments
            : selectedAssignments // ignore: cast_nullable_to_non_nullable
                  as List<Assignment>,
        recipientSelection: freezed == recipientSelection
            ? _value.recipientSelection
            : recipientSelection // ignore: cast_nullable_to_non_nullable
                  as RecipientSelectionResult?,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        availableFrom: freezed == availableFrom
            ? _value.availableFrom
            : availableFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        availableUntil: freezed == availableUntil
            ? _value.availableUntil
            : availableUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        timeLimitMinutes: freezed == timeLimitMinutes
            ? _value.timeLimitMinutes
            : timeLimitMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        allowLate: null == allowLate
            ? _value.allowLate
            : allowLate // ignore: cast_nullable_to_non_nullable
                  as bool,
        latePenaltyPercent: null == latePenaltyPercent
            ? _value.latePenaltyPercent
            : latePenaltyPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        showScoreImmediately: null == showScoreImmediately
            ? _value.showScoreImmediately
            : showScoreImmediately // ignore: cast_nullable_to_non_nullable
                  as bool,
        sendNotification: null == sendNotification
            ? _value.sendNotification
            : sendNotification // ignore: cast_nullable_to_non_nullable
                  as bool,
        shuffleQuestions: null == shuffleQuestions
            ? _value.shuffleQuestions
            : shuffleQuestions // ignore: cast_nullable_to_non_nullable
                  as bool,
        shuffleAnswers: null == shuffleAnswers
            ? _value.shuffleAnswers
            : shuffleAnswers // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuccess: null == isSuccess
            ? _value.isSuccess
            : isSuccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DistributeAssignmentStateImpl implements _DistributeAssignmentState {
  const _$DistributeAssignmentStateImpl({
    this.assignment,
    final List<Assignment> selectedAssignments = const [],
    this.recipientSelection,
    this.dueDate,
    this.availableFrom,
    this.availableUntil,
    this.timeLimitMinutes = null,
    this.allowLate = true,
    this.latePenaltyPercent = 10,
    this.showScoreImmediately = true,
    this.sendNotification = true,
    this.shuffleQuestions = false,
    this.shuffleAnswers = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  }) : _selectedAssignments = selectedAssignments;

  // Dữ liệu bài tập (optional – nếu được truyền vào từ hub/list)
  @override
  final Assignment? assignment;
  // Danh sách bài tập được chọn (hỗ trợ phân phối nhiều bài cùng lúc)
  final List<Assignment> _selectedAssignments;
  // Danh sách bài tập được chọn (hỗ trợ phân phối nhiều bài cùng lúc)
  @override
  @JsonKey()
  List<Assignment> get selectedAssignments {
    if (_selectedAssignments is EqualUnmodifiableListView)
      return _selectedAssignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedAssignments);
  }

  // --- Đối tượng nhận bài (Tree Selection) ---
  @override
  final RecipientSelectionResult? recipientSelection;
  // --- Thời gian ---
  @override
  final DateTime? dueDate;
  // Ngày giờ nộp bài
  @override
  final DateTime? availableFrom;
  // Ngày giờ mở bài (null = ngay lập tức)
  @override
  final DateTime? availableUntil;
  // Ngày giờ đóng bài (null = không giới hạn)
  @override
  @JsonKey()
  final int? timeLimitMinutes;
  // Giới hạn thời gian làm bài (phút)
  // --- Cài đặt nâng cao ---
  @override
  @JsonKey()
  final bool allowLate;
  // Cho phép nộp muộn
  @override
  @JsonKey()
  final int latePenaltyPercent;
  // Phần trăm trừ điểm mỗi ngày trễ
  @override
  @JsonKey()
  final bool showScoreImmediately;
  // Hiển thị điểm ngay sau khi nộp
  @override
  @JsonKey()
  final bool sendNotification;
  // Gửi thông báo cho học sinh
  @override
  @JsonKey()
  final bool shuffleQuestions;
  // Đảo câu hỏi
  @override
  @JsonKey()
  final bool shuffleAnswers;
  // Đảo đáp án
  // --- UI State ---
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'DistributeAssignmentState(assignment: $assignment, selectedAssignments: $selectedAssignments, recipientSelection: $recipientSelection, dueDate: $dueDate, availableFrom: $availableFrom, availableUntil: $availableUntil, timeLimitMinutes: $timeLimitMinutes, allowLate: $allowLate, latePenaltyPercent: $latePenaltyPercent, showScoreImmediately: $showScoreImmediately, sendNotification: $sendNotification, shuffleQuestions: $shuffleQuestions, shuffleAnswers: $shuffleAnswers, isLoading: $isLoading, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DistributeAssignmentStateImpl &&
            (identical(other.assignment, assignment) ||
                other.assignment == assignment) &&
            const DeepCollectionEquality().equals(
              other._selectedAssignments,
              _selectedAssignments,
            ) &&
            (identical(other.recipientSelection, recipientSelection) ||
                other.recipientSelection == recipientSelection) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.availableFrom, availableFrom) ||
                other.availableFrom == availableFrom) &&
            (identical(other.availableUntil, availableUntil) ||
                other.availableUntil == availableUntil) &&
            (identical(other.timeLimitMinutes, timeLimitMinutes) ||
                other.timeLimitMinutes == timeLimitMinutes) &&
            (identical(other.allowLate, allowLate) ||
                other.allowLate == allowLate) &&
            (identical(other.latePenaltyPercent, latePenaltyPercent) ||
                other.latePenaltyPercent == latePenaltyPercent) &&
            (identical(other.showScoreImmediately, showScoreImmediately) ||
                other.showScoreImmediately == showScoreImmediately) &&
            (identical(other.sendNotification, sendNotification) ||
                other.sendNotification == sendNotification) &&
            (identical(other.shuffleQuestions, shuffleQuestions) ||
                other.shuffleQuestions == shuffleQuestions) &&
            (identical(other.shuffleAnswers, shuffleAnswers) ||
                other.shuffleAnswers == shuffleAnswers) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    assignment,
    const DeepCollectionEquality().hash(_selectedAssignments),
    recipientSelection,
    dueDate,
    availableFrom,
    availableUntil,
    timeLimitMinutes,
    allowLate,
    latePenaltyPercent,
    showScoreImmediately,
    sendNotification,
    shuffleQuestions,
    shuffleAnswers,
    isLoading,
    isSuccess,
    errorMessage,
  );

  /// Create a copy of DistributeAssignmentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DistributeAssignmentStateImplCopyWith<_$DistributeAssignmentStateImpl>
  get copyWith =>
      __$$DistributeAssignmentStateImplCopyWithImpl<
        _$DistributeAssignmentStateImpl
      >(this, _$identity);
}

abstract class _DistributeAssignmentState implements DistributeAssignmentState {
  const factory _DistributeAssignmentState({
    final Assignment? assignment,
    final List<Assignment> selectedAssignments,
    final RecipientSelectionResult? recipientSelection,
    final DateTime? dueDate,
    final DateTime? availableFrom,
    final DateTime? availableUntil,
    final int? timeLimitMinutes,
    final bool allowLate,
    final int latePenaltyPercent,
    final bool showScoreImmediately,
    final bool sendNotification,
    final bool shuffleQuestions,
    final bool shuffleAnswers,
    final bool isLoading,
    final bool isSuccess,
    final String? errorMessage,
  }) = _$DistributeAssignmentStateImpl;

  // Dữ liệu bài tập (optional – nếu được truyền vào từ hub/list)
  @override
  Assignment? get assignment; // Danh sách bài tập được chọn (hỗ trợ phân phối nhiều bài cùng lúc)
  @override
  List<Assignment> get selectedAssignments; // --- Đối tượng nhận bài (Tree Selection) ---
  @override
  RecipientSelectionResult? get recipientSelection; // --- Thời gian ---
  @override
  DateTime? get dueDate; // Ngày giờ nộp bài
  @override
  DateTime? get availableFrom; // Ngày giờ mở bài (null = ngay lập tức)
  @override
  DateTime? get availableUntil; // Ngày giờ đóng bài (null = không giới hạn)
  @override
  int? get timeLimitMinutes; // Giới hạn thời gian làm bài (phút)
  // --- Cài đặt nâng cao ---
  @override
  bool get allowLate; // Cho phép nộp muộn
  @override
  int get latePenaltyPercent; // Phần trăm trừ điểm mỗi ngày trễ
  @override
  bool get showScoreImmediately; // Hiển thị điểm ngay sau khi nộp
  @override
  bool get sendNotification; // Gửi thông báo cho học sinh
  @override
  bool get shuffleQuestions; // Đảo câu hỏi
  @override
  bool get shuffleAnswers; // Đảo đáp án
  // --- UI State ---
  @override
  bool get isLoading;
  @override
  bool get isSuccess;
  @override
  String? get errorMessage;

  /// Create a copy of DistributeAssignmentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DistributeAssignmentStateImplCopyWith<_$DistributeAssignmentStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
