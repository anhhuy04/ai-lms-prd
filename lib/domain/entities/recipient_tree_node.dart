import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipient_tree_node.freezed.dart';
part 'recipient_tree_node.g.dart';

@freezed
class StudentNode with _$StudentNode {
  const factory StudentNode({
    required String id,
    required String name,
    double? score,
    String? note,
  }) = _StudentNode;

  factory StudentNode.fromJson(Map<String, dynamic> json) =>
      _$StudentNodeFromJson(json);
}

@freezed
class GroupNode with _$GroupNode {
  const factory GroupNode({
    required String id,
    required String name,
    @Default([]) List<StudentNode> students,
  }) = _GroupNode;

  factory GroupNode.fromJson(Map<String, dynamic> json) =>
      _$GroupNodeFromJson(json);
}

@freezed
class ClassNode with _$ClassNode {
  const factory ClassNode({
    required String id,
    required String name,
    @Default(0) int totalStudents,
    @Default([]) List<GroupNode> groups,
    @Default([]) List<StudentNode> independentStudents,
  }) = _ClassNode;

  factory ClassNode.fromJson(Map<String, dynamic> json) =>
      _$ClassNodeFromJson(json);
}
