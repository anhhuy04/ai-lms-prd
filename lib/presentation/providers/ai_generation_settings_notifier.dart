import 'package:ai_mls/domain/entities/template_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_generation_settings_notifier.g.dart';

enum ProcessingMode { promptOnly, extraction, ragGeneration }

class AiGenerationConfig {
  const AiGenerationConfig({
    this.processingMode = ProcessingMode.promptOnly,
    this.selectedFileIds = const [],
    this.templateMode = TemplateMode.styleOnly,
  });

  final ProcessingMode processingMode;
  final List<String> selectedFileIds;

  /// Sub-mode khi Mode 3 detect tài liệu là template. Default = styleOnly.
  /// Chỉ có ý nghĩa khi `processingMode == ragGeneration` và file detect là
  /// template; flow khác bỏ qua field này.
  final TemplateMode templateMode;

  AiGenerationConfig copyWith({
    ProcessingMode? processingMode,
    List<String>? selectedFileIds,
    TemplateMode? templateMode,
  }) {
    return AiGenerationConfig(
      processingMode: processingMode ?? this.processingMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
      templateMode: templateMode ?? this.templateMode,
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

  void setTemplateMode(TemplateMode mode) =>
      state = state.copyWith(templateMode: mode);
}
