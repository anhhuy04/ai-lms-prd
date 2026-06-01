// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bank_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionBankSummaryHash() =>
    r'9a1c180b23e92ae388c6a40348785a59dad4681e';

/// Gọi RPC `get_question_bank_summary()` — SELECT COUNT(*) server-side,
/// scope theo `auth.uid()`. Thay thế fetch-1000-then-filter (Bug #3).
///
/// Copied from [questionBankSummary].
@ProviderFor(questionBankSummary)
final questionBankSummaryProvider =
    AutoDisposeFutureProvider<QuestionBankSummary>.internal(
      questionBankSummary,
      name: r'questionBankSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$questionBankSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuestionBankSummaryRef =
    AutoDisposeFutureProviderRef<QuestionBankSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
