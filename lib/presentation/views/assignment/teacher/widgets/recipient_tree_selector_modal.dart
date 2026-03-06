import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/domain/entities/recipient_tree_node.dart';
import 'package:ai_mls/presentation/providers/auth_providers.dart';
import 'package:ai_mls/presentation/providers/class_providers.dart';
import 'package:ai_mls/widgets/loading/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kết quả trả về sau khi người dùng ấn "Xác nhận"
class RecipientSelectionResult {
  /// Danh sách ID của các Lớp được chọn TOÀN BỘ
  final Set<String> fullySelectedClassIds;

  /// Lớp ID -> Danh sách ID của Nhóm được chọn
  final Map<String, Set<String>> selectedGroupIdsByClass;

  /// Lớp ID -> Danh sách ID của Học Sinh lẻ được chọn
  final Map<String, Set<String>> selectedStudentIdsByClass;

  RecipientSelectionResult({
    required this.fullySelectedClassIds,
    required this.selectedGroupIdsByClass,
    required this.selectedStudentIdsByClass,
  });

  RecipientSelectionResult copyWith({
    Set<String>? fullySelectedClassIds,
    Map<String, Set<String>>? selectedGroupIdsByClass,
    Map<String, Set<String>>? selectedStudentIdsByClass,
  }) {
    return RecipientSelectionResult(
      fullySelectedClassIds:
          fullySelectedClassIds ?? this.fullySelectedClassIds,
      selectedGroupIdsByClass:
          selectedGroupIdsByClass ?? this.selectedGroupIdsByClass,
      selectedStudentIdsByClass:
          selectedStudentIdsByClass ?? this.selectedStudentIdsByClass,
    );
  }

  int get totalClasses => fullySelectedClassIds.length;
  int get totalGroups =>
      selectedGroupIdsByClass.values.fold(0, (sum, set) => sum + set.length);
  int get totalStudents =>
      selectedStudentIdsByClass.values.fold(0, (sum, set) => sum + set.length);

  bool get isEmpty =>
      fullySelectedClassIds.isEmpty &&
      selectedGroupIdsByClass.isEmpty &&
      selectedStudentIdsByClass.isEmpty;
}

enum RecipientTreeFilter {
  all('Tất cả sơ đồ', 'Cấu trúc đầy đủ: Lớp > Nhóm > Học sinh'),
  classAndGroup('Lớp học và nhóm học', 'Chỉ hiển thị Lớp và Nhóm trực thuộc'),
  classAndStudent(
    'Lớp học và học sinh',
    'Hiển thị Lớp và tất thảy Học sinh (bỏ qua Nhóm)',
  ),
  groupAndStudent(
    'Nhóm liên thông',
    'Các nhóm học riêng biệt không cùng lớp hành chính',
  );

  final String title;
  final String description;
  const RecipientTreeFilter(this.title, this.description);
}

class RecipientTreeSelectorModal extends ConsumerStatefulWidget {
  final List<ClassNode> data;
  final RecipientSelectionResult? initialSelection;

  final String title;
  final String confirmText;

  const RecipientTreeSelectorModal({
    super.key,
    required this.data,
    this.initialSelection,
    this.title = 'Chọn đối tượng',
    this.confirmText = 'Xác nhận',
  });

  /// Hiển thị dạng BottomSheet
  static Future<RecipientSelectionResult?> show(
    BuildContext context, {
    required List<ClassNode> data,
    RecipientSelectionResult? initialSelection,
    String title = 'Chọn đối tượng',
    String confirmText = 'Xác nhận',
  }) {
    return showModalBottomSheet<RecipientSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top:
              MediaQuery.of(ctx).size.height *
              0.1, // Chừa khoảng trống phía trên 10%
        ),
        child: RecipientTreeSelectorModal(
          data: data,
          initialSelection: initialSelection,
          title: title,
          confirmText: confirmText,
        ),
      ),
    );
  }

  @override
  ConsumerState<RecipientTreeSelectorModal> createState() =>
      _RecipientTreeSelectorModalState();
}

class _RecipientTreeSelectorModalState
    extends ConsumerState<RecipientTreeSelectorModal> {
  // --- Local State for Tree Selection ---
  // Composite keys để tránh cross-class leakage:
  // - Class: classId (unique)
  // - Group: 'classId::groupId'
  // - Student: 'classId::studentId'
  final Set<String> _checkedIds = {};

  // Mapping groupId → classId (cho groupAndStudent filter mode)
  final Map<String, String> _groupToClassMap = {};

  // --- Composite Key Helpers ---
  String _groupKey(String classId, String groupId) => '$classId::$groupId';
  String _studentKey(String classId, String studentId) =>
      '$classId::$studentId';

  // Trạng thái mở rộng của các Lớp
  final Set<String> _expandedClassIds = {};

  RecipientTreeFilter _currentFilter = RecipientTreeFilter.all;

  // Trạng thái mở rộng của các Nhóm
  final Set<String> _expandedGroupIds = {};

  String _searchQuery = '';

  // Data từ provider (sẽ load khi mở modal)
  List<ClassNode> _loadedData = [];

  // Pagination state
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    final totalItems = _filteredData.length;
    if (_currentPage * _pageSize >= totalItems) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Simulate small delay for smooth loading
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<ClassNode> get _paginatedData {
    final filtered = _filteredData;
    final endIndex = (_currentPage + 1) * _pageSize;
    if (endIndex >= filtered.length) return filtered;
    return filtered.sublist(0, endIndex);
  }

  List<GroupNode> _paginatedGroups(List<GroupNode> allGroups) {
    final endIndex = (_currentPage + 1) * _pageSize;
    if (endIndex >= allGroups.length) return allGroups;
    return allGroups.sublist(0, endIndex);
  }

  Widget _buildPaginatedList<T>({
    required List<T> items,
    required int totalItems,
    required Widget Function(BuildContext, int) itemBuilder,
    required String listType,
  }) {
    final hasMore = totalItems > items.length;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        if (i >= items.length) {
          // Loading indicator
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return itemBuilder(ctx, i);
      },
    );
  }

  Future<void> _loadData() async {
    // Reset pagination when loading new data
    _currentPage = 0;

    // Nếu có data truyền vào (từ cache) thì dùng luôn
    if (widget.data.isNotEmpty) {
      setState(() {
        _loadedData = widget.data;
      });
      _initSelection();
      return;
    }

    // Load từ database - tối ưu với Future.wait
    final repository = ref.read(schoolClassRepositoryProvider);
    final teacherId = ref.read(currentUserIdProvider);

    if (teacherId == null) return;

    try {
      final classes = await repository.getClassesByTeacher(teacherId);

      if (classes.isEmpty) {
        if (mounted) {
          setState(() {
            _loadedData = [];
          });
        }
        return;
      }

      // Tối ưu: Gọi song song tất cả API
      final memberFutures = classes
          .map((c) => repository.getClassMembers(c.id, status: 'approved'))
          .toList();

      final groupFutures = classes
          .map((c) => repository.getGroupsByClass(c.id))
          .toList();

      final allMembersResults = await Future.wait(memberFutures);
      final allGroupsResults = await Future.wait(groupFutures);

      // Xử lý từng lớp
      final classNodes = <ClassNode>[];

      for (int i = 0; i < classes.length; i++) {
        final classEntity = classes[i];
        final members = allMembersResults[i];
        final groups = allGroupsResults[i];

        // Gọi song song group members
        final groupMemberFutures = groups.isEmpty
            ? <Future<List<dynamic>>>[]
            : groups.map((g) => repository.getGroupMembers(g.id)).toList();

        final allGroupMembers = groupMemberFutures.isEmpty
            ? <List<dynamic>>[]
            : await Future.wait(groupMemberFutures);

        final groupNodes = <GroupNode>[];
        final independentStudentIds = <String>{};

        for (int j = 0; j < groups.length; j++) {
          final group = groups[j];
          final groupMembers = allGroupMembers[j];

          final studentNodes = groupMembers
              .map(
                (gm) => StudentNode(
                  id: gm.studentId,
                  name: 'HS ${gm.studentId.substring(0, 8)}',
                ),
              )
              .toList();

          groupNodes.add(
            GroupNode(id: group.id, name: group.name, students: studentNodes),
          );
          independentStudentIds.addAll(groupMembers.map((gm) => gm.studentId));
        }

        final independentStudents = members
            .where((m) => !independentStudentIds.contains(m.studentId))
            .map(
              (m) => StudentNode(
                id: m.studentId,
                name: 'HS ${m.studentId.substring(0, 8)}',
              ),
            )
            .toList();

        // Build groupId → classId mapping
        for (final g in groupNodes) {
          _groupToClassMap[g.id] = classEntity.id;
        }

        classNodes.add(
          ClassNode(
            id: classEntity.id,
            name: classEntity.name,
            totalStudents: members.length,
            groups: groupNodes,
            independentStudents: independentStudents,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _loadedData = classNodes;
        });
        _initSelection();
      }
    } catch (e) {
      // Silently handle error - UI will show empty state
    }
  }

  void _initSelection() {
    if (widget.initialSelection == null) return;

    // Khôi phục Selection (dùng composite keys)
    final sel = widget.initialSelection!;

    for (final classId in sel.fullySelectedClassIds) {
      _checkedIds.add(classId);
      for (final c in _loadedData) {
        if (c.id == classId) {
          for (final g in c.groups) {
            _checkedIds.add(_groupKey(classId, g.id));
            for (final s in g.students) {
              _checkedIds.add(_studentKey(classId, s.id));
            }
          }
          for (final s in c.independentStudents) {
            _checkedIds.add(_studentKey(classId, s.id));
          }
          break;
        }
      }
    }

    sel.selectedGroupIdsByClass.forEach((classId, groupIds) {
      for (final c in _loadedData) {
        if (c.id == classId) {
          for (final g in c.groups) {
            if (groupIds.contains(g.id)) {
              _checkedIds.add(_groupKey(classId, g.id));
              for (final s in g.students) {
                _checkedIds.add(_studentKey(classId, s.id));
              }
            }
          }
          break;
        }
      }
    });

    sel.selectedStudentIdsByClass.forEach((classId, studentIds) {
      for (final sid in studentIds) {
        _checkedIds.add(_studentKey(classId, sid));
      }
    });

    _syncParentStates();
  }

  /// Trả về true nếu TOÀN BỘ con cháu của class này được check
  bool _isClassFullyChecked(ClassNode c) {
    if (c.groups.isEmpty && c.independentStudents.isEmpty) {
      return _checkedIds.contains(c.id);
    }

    for (final g in c.groups) {
      if (!_isGroupFullyChecked(c.id, g)) return false;
    }
    for (final s in c.independentStudents) {
      if (!_checkedIds.contains(_studentKey(c.id, s.id))) return false;
    }
    return true;
  }

  /// Trả về true nếu ÍT NHẤT 1 (nhưng KHÔNG PHẢI TẤT CẢ) con cháu được check
  bool _isClassPartiallyChecked(ClassNode c) {
    if (_isClassFullyChecked(c)) return false;

    for (final g in c.groups) {
      if (_isGroupFullyChecked(c.id, g) || _isGroupPartiallyChecked(c.id, g)) {
        return true;
      }
    }
    for (final s in c.independentStudents) {
      if (_checkedIds.contains(_studentKey(c.id, s.id))) return true;
    }
    return false;
  }

  bool _isGroupFullyChecked(String classId, GroupNode g) {
    if (g.students.isEmpty) {
      return _checkedIds.contains(_groupKey(classId, g.id));
    }
    for (final s in g.students) {
      if (!_checkedIds.contains(_studentKey(classId, s.id))) return false;
    }
    return true;
  }

  bool _isGroupPartiallyChecked(String classId, GroupNode g) {
    if (_isGroupFullyChecked(classId, g)) return false;
    for (final s in g.students) {
      if (_checkedIds.contains(_studentKey(classId, s.id))) return true;
    }
    return false;
  }

  /// Đồng bộ state: Nếu đủ con thì bật cha (dùng composite keys)
  void _syncParentStates() {
    for (final c in _loadedData) {
      // Group sync
      for (final g in c.groups) {
        if (g.students.isNotEmpty) {
          final allStudentsChecked = g.students.every(
            (s) => _checkedIds.contains(_studentKey(c.id, s.id)),
          );
          if (allStudentsChecked) {
            _checkedIds.add(_groupKey(c.id, g.id));
          } else {
            _checkedIds.remove(_groupKey(c.id, g.id));
          }
        }
      }

      // Class sync
      final allGroupsChecked = c.groups.every(
        (g) => _checkedIds.contains(_groupKey(c.id, g.id)),
      );
      final allIndChecked = c.independentStudents.every(
        (s) => _checkedIds.contains(_studentKey(c.id, s.id)),
      );
      if (allGroupsChecked &&
          allIndChecked &&
          (c.groups.isNotEmpty || c.independentStudents.isNotEmpty)) {
        _checkedIds.add(c.id);
      } else {
        _checkedIds.remove(c.id);
      }
    }
  }

  void _onToggleClass(ClassNode c, bool? value) {
    setState(() {
      final isChecking = value ?? false;
      if (isChecking) {
        _checkedIds.add(c.id);
        for (final g in c.groups) {
          _checkedIds.add(_groupKey(c.id, g.id));
          for (final s in g.students) {
            _checkedIds.add(_studentKey(c.id, s.id));
          }
        }
        for (final s in c.independentStudents) {
          _checkedIds.add(_studentKey(c.id, s.id));
        }
      } else {
        _checkedIds.remove(c.id);
        for (final g in c.groups) {
          _checkedIds.remove(_groupKey(c.id, g.id));
          for (final s in g.students) {
            _checkedIds.remove(_studentKey(c.id, s.id));
          }
        }
        for (final s in c.independentStudents) {
          _checkedIds.remove(_studentKey(c.id, s.id));
        }
      }
      _syncParentStates();
    });
  }

  void _onToggleGroup(String classId, GroupNode g, bool? value) {
    setState(() {
      final isChecking = value ?? false;
      if (isChecking) {
        _checkedIds.add(_groupKey(classId, g.id));
        for (final s in g.students) {
          _checkedIds.add(_studentKey(classId, s.id));
        }
      } else {
        _checkedIds.remove(_groupKey(classId, g.id));
        for (final s in g.students) {
          _checkedIds.remove(_studentKey(classId, s.id));
        }
      }
      _syncParentStates();
    });
  }

  void _onToggleStudent(String classId, StudentNode s, bool? value) {
    setState(() {
      final isChecking = value ?? false;
      if (isChecking) {
        _checkedIds.add(_studentKey(classId, s.id));
      } else {
        _checkedIds.remove(_studentKey(classId, s.id));
      }
      _syncParentStates();
    });
  }

  void _onConfirm() {
    final fullySelectedClassIds = <String>{};
    final selectedGroupIdsByClass = <String, Set<String>>{};
    final selectedStudentIdsByClass = <String, Set<String>>{};

    for (final c in _loadedData) {
      if (_isClassFullyChecked(c)) {
        fullySelectedClassIds.add(c.id);
        continue;
      }

      final classGroupIds = <String>{};
      final classStudentIds = <String>{};

      for (final g in c.groups) {
        if (_isGroupFullyChecked(c.id, g)) {
          classGroupIds.add(g.id);
        } else if (_isGroupPartiallyChecked(c.id, g)) {
          // Chỉ lấy các học sinh lẻ trong nhóm này
          for (final s in g.students) {
            if (_checkedIds.contains(_studentKey(c.id, s.id))) {
              classStudentIds.add(s.id);
            }
          }
        }
      }

      for (final s in c.independentStudents) {
        if (_checkedIds.contains(_studentKey(c.id, s.id))) {
          classStudentIds.add(s.id);
        }
      }

      if (classGroupIds.isNotEmpty) {
        selectedGroupIdsByClass[c.id] = classGroupIds;
      }
      if (classStudentIds.isNotEmpty) {
        selectedStudentIdsByClass[c.id] = classStudentIds;
      }
    }

    Navigator.pop(
      context,
      RecipientSelectionResult(
        fullySelectedClassIds: fullySelectedClassIds,
        selectedGroupIdsByClass: selectedGroupIdsByClass,
        selectedStudentIdsByClass: selectedStudentIdsByClass,
      ),
    );
  }

  // --- Search Filtering ---
  List<ClassNode> get _filteredData {
    if (_searchQuery.isEmpty) return _loadedData;

    final q = _searchQuery.toLowerCase();
    final result = <ClassNode>[];

    for (final c in _loadedData) {
      if (_currentFilter == RecipientTreeFilter.groupAndStudent) {
        if (c.id != 'inter_class_root') continue;
      } else {
        if (c.id == 'inter_class_root') continue;
      }

      // Nếu tên lớp match thì hiện cả lớp
      if (c.name.toLowerCase().contains(q)) {
        result.add(c);
        continue;
      }

      final filteredGroups = <GroupNode>[];
      for (final g in c.groups) {
        if (g.name.toLowerCase().contains(q)) {
          filteredGroups.add(g);
        } else {
          final mappedStudents = g.students
              .where((s) => s.name.toLowerCase().contains(q))
              .toList();
          if (mappedStudents.isNotEmpty) {
            filteredGroups.add(g.copyWith(students: mappedStudents));
          }
        }
      }

      final filteredStudents = c.independentStudents
          .where((s) => s.name.toLowerCase().contains(q))
          .toList();

      if (filteredGroups.isNotEmpty || filteredStudents.isNotEmpty) {
        result.add(
          c.copyWith(
            groups: filteredGroups,
            independentStudents: filteredStudents,
          ),
        );
      }
    }

    return result;
  }

  // --- UI Builders ---
  /// Đếm số lượng đối tượng đã chọn (classes + groups + student sets)
  int _getSelectedItemCount() {
    int count = 0;
    for (final c in _loadedData) {
      if (_isClassFullyChecked(c)) {
        count++; // Cả lớp
        continue;
      }
      for (final g in c.groups) {
        if (_isGroupFullyChecked(c.id, g)) {
          count++; // Nhóm fully checked
        } else if (_isGroupPartiallyChecked(c.id, g)) {
          count++; // Nhóm partially checked (học sinh lẻ)
        }
      }
      for (final s in c.independentStudents) {
        if (_checkedIds.contains(_studentKey(c.id, s.id))) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final filteredNodes = _filteredData;
    final paginatedNodes = _paginatedData;
    final totalNodesSelected =
        _checkedIds.length; // Approximate, but mainly to show > 0

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: DesignTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111418),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Box & Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 0; // Reset page when searching
                        // Tự động mở rộng cây nếu đang tìm kiếm
                        if (val.isNotEmpty) {
                          _expandedClassIds.addAll(
                            _loadedData.map((c) => c.id),
                          );
                          _expandedGroupIds.addAll(
                            _loadedData.expand(
                              (c) => c.groups.map((g) => g.id),
                            ),
                          );
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm lớp, nhóm hoặc học sinh...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF137fec),
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: DesignTypography.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<RecipientTreeFilter>(
                  tooltip: 'Tùy chọn hiển thị đối tượng',
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  onSelected: (filter) => setState(() {
                    _currentFilter = filter;
                    _currentPage = 0; // Reset page when filter changes
                  }),
                  itemBuilder: (context) => RecipientTreeFilter.values
                      .map(
                        (f) => PopupMenuItem(
                          value: f,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    f.title,
                                    style: DesignTypography.bodyMedium.copyWith(
                                      fontWeight: _currentFilter == f
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _currentFilter == f
                                          ? const Color(0xFF137fec)
                                          : const Color(0xFF111418),
                                    ),
                                  ),
                                  if (_currentFilter == f) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Color(0xFF137fec),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                f.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(8),
                      color: _currentFilter == RecipientTreeFilter.all
                          ? Colors.white
                          : const Color(0xFFEFF6FF),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          color: _currentFilter == RecipientTreeFilter.all
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF137fec),
                        ),
                        if (_currentFilter != RecipientTreeFilter.all) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Tree with pagination
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: Builder(
                builder: (context) {
                  // Hiển thị shimmer khi đang load
                  if (_loadedData.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerLoading(),
                    );
                  }

                  if (filteredNodes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.school_outlined
                                : Icons.search_off,
                            size: 64,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Chưa có lớp học nào'
                                : 'Không tìm thấy kết quả phù hợp.',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 16,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Tạo lớp học để phân phối bài tập',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  if (_currentFilter == RecipientTreeFilter.groupAndStudent) {
                    final flatGroups = filteredNodes
                        .expand((c) => c.groups)
                        .toList();
                    if (flatGroups.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Không có nhóm nào.'
                              : 'Không tìm thấy nhóm phù hợp.',
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      );
                    }
                    // Paginate groupAndStudent filter
                    final paginatedGroups = _paginatedGroups(flatGroups);
                    return _buildPaginatedList(
                      items: paginatedGroups,
                      totalItems: flatGroups.length,
                      itemBuilder: (ctx, i) =>
                          _buildRootGroupNode(paginatedGroups[i]),
                      listType: 'groups',
                    );
                  }

                  // Paginated list for normal filter
                  return _buildPaginatedList(
                    items: paginatedNodes,
                    totalItems: filteredNodes.length,
                    itemBuilder: (ctx, i) => _buildClassNode(paginatedNodes[i]),
                    listType: 'classes',
                  );
                },
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(
              16,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, -4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: const Color(0xFF4B5563),
                    ),
                    child: const Text(
                      'Hủy bỏ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: totalNodesSelected > 0 ? _onConfirm : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF137fec),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '${widget.confirmText} (${_getSelectedItemCount()})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Node Builders ---
  Widget _buildClassNode(ClassNode node) {
    final isExpanded = _expandedClassIds.contains(node.id);
    final isFullyChecked = _isClassFullyChecked(node);
    final isPartiallyChecked = _isClassPartiallyChecked(node);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Class Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedClassIds.remove(node.id);
                } else {
                  _expandedClassIds.add(node.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: isFullyChecked
                        ? true
                        : (isPartiallyChecked ? null : false),
                    tristate: true,
                    activeColor: const Color(0xFF137fec),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    onChanged: (val) =>
                        _onToggleClass(node, isPartiallyChecked ? true : val),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.name,
                          style: DesignTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111418),
                          ),
                        ),
                        Text(
                          '${node.totalStudents} học sinh • Sĩ số đủ',
                          style: DesignTypography.bodySmall.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Children (Goups and Independent Students)
          if (isExpanded) ...[
            Container(color: const Color(0xFFF3F4F6), height: 1), // Divider
            Container(
              padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
              child: Column(
                children: [
                  if (_currentFilter != RecipientTreeFilter.classAndStudent)
                    ...node.groups.map((g) => _buildGroupTree(node.id, g)),

                  if (_currentFilter ==
                      RecipientTreeFilter.classAndStudent) ...[
                    ...node.independentStudents.map(
                      (s) => _buildStudentLeaf(node.id, s),
                    ),
                    ...node.groups
                        .expand((g) => g.students)
                        .map((s) => _buildStudentLeaf(node.id, s)),
                  ] else if (_currentFilter !=
                      RecipientTreeFilter.classAndGroup)
                    ...node.independentStudents.map(
                      (s) => _buildStudentLeaf(node.id, s),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRootGroupNode(GroupNode group) {
    // Tìm classId context cho group này
    final classId = _groupToClassMap[group.id] ?? '';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: _buildGroupTree(classId, group, isRoot: true),
    );
  }

  Widget _buildGroupTree(
    String classId,
    GroupNode group, {
    bool isRoot = false,
  }) {
    final isFullyChecked = _isGroupFullyChecked(classId, group);
    final isPartiallyChecked = _isGroupPartiallyChecked(classId, group);
    final hasStudents = group.students.isNotEmpty;
    final isExpanded = _expandedGroupIds.contains(group.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedGroupIds.remove(group.id);
              } else {
                _expandedGroupIds.add(group.id);
              }
            });
          },
          child: Padding(
            padding: isRoot
                ? const EdgeInsets.all(12)
                : const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: isFullyChecked
                      ? true
                      : (isPartiallyChecked ? null : false),
                  tristate: true,
                  activeColor: const Color(0xFF137fec),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  onChanged: (val) => _onToggleGroup(
                    classId,
                    group,
                    isPartiallyChecked ? true : val,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF2563EB),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: DesignTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111418),
                        ),
                      ),
                      Text(
                        '${group.students.length} học sinh',
                        style: DesignTypography.caption.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasStudents &&
            isExpanded &&
            _currentFilter != RecipientTreeFilter.classAndGroup) ...[
          if (isRoot) Container(color: const Color(0xFFF3F4F6), height: 1),
          Padding(
            padding: isRoot
                ? const EdgeInsets.only(left: 20, top: 4, bottom: 4)
                : const EdgeInsets.only(left: 48),
            child: Column(
              children: group.students
                  .map((s) => _buildStudentLeaf(classId, s))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStudentLeaf(String classId, StudentNode s) {
    final isChecked = _checkedIds.contains(_studentKey(classId, s.id));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: const Color(0xFF137fec),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            onChanged: (val) => _onToggleStudent(classId, s, val),
          ),
          const SizedBox(width: 12),
          // Circle Avatar placeholder
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                s.name.substring(0, 1),
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: DesignTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111418),
                  ),
                ),
                if (s.score != null)
                  Text(
                    'Điểm TB: ${s.score}',
                    style: DesignTypography.caption.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
