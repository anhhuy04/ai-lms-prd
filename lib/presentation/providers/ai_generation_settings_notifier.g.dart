// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_generation_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiGenerationSettingsNotifierHash() =>
    r'cfca140bfbdb6a8a647ecda68248421905b20484';

/// Session-scoped AI generation settings (keepAlive = persists until app restart).
/// Shared between AiQuestionSettingsScreen and TeacherAiGenerateQuestionScreen.
///
/// Copied from [AiGenerationSettingsNotifier].
@ProviderFor(AiGenerationSettingsNotifier)
final aiGenerationSettingsNotifierProvider =
    NotifierProvider<AiGenerationSettingsNotifier, AiGenerationConfig>.internal(
      AiGenerationSettingsNotifier.new,
      name: r'aiGenerationSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiGenerationSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AiGenerationSettingsNotifier = Notifier<AiGenerationConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
