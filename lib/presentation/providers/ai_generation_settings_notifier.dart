import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_generation_settings_notifier.g.dart';

enum ProcessingMode { promptOnly, extraction, ragGeneration }

class AiGenerationConfig {
  const AiGenerationConfig({
    this.processingMode = ProcessingMode.promptOnly,
    this.selectedFileIds = const [],
  });

  final ProcessingMode processingMode;
  final List<String> selectedFileIds;

  AiGenerationConfig copyWith({
    ProcessingMode? processingMode,
    List<String>? selectedFileIds,
  }) {
    return AiGenerationConfig(
      processingMode: processingMode ?? this.processingMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
    );
  }
}

/// Session-scoped AI generation settings (keepAlive = persists until app restart).
/// Shared between AiQuestionSettingsScreen and TeacherAiGenerateQuestionScreen.
@Riverpod(keepAlive: true)
class AiGenerationSettingsNotifier extends _$AiGenerationSettingsNotifier {
  @override
  AiGenerationConfig build() => const AiGenerationConfig();

  void setMode(ProcessingMode mode) =>
      state = state.copyWith(processingMode: mode);

  void setSelectedFileIds(List<String> ids) =>
      state = state.copyWith(selectedFileIds: ids);
}
