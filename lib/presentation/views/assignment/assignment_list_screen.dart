import 'package:flutter/material.dart';
import 'package:ai_mls/core/constants/design_tokens.dart';
import 'package:ai_mls/widgets/search_field.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  String _searchQuery = '';

  // Dữ liệu mẫu cho danh sách bài tập
  final List<Map<String, dynamic>> sampleAssignments = [
    {
      'id': '1',
      'title': 'Bài tập Toán - Phương trình bậc 2',
      'className': 'Toán Học - Lớp 10A2',
      'dueDate': '2024-01-20',
      'status': 'pending',
      'submissions': 15,
      'total': 32,
    },
    {
      'id': '2',
      'title': 'Thí nghiệm Vật Lý: Động lực học',
      'className': 'Vật Lý - Lớp 11B1',
      'dueDate': '2024-01-18',
      'status': 'overdue',
      'submissions': 38,
      'total': 40,
    },
    {
      'id': '3',
      'title': 'Bài luận Ngữ Văn: Tình yêu quê hương',
      'className': 'Ngữ Văn - Lớp 12C3',
      'dueDate': '2024-01-25',
      'status': 'active',
      'submissions': 22,
      'total': 35,
    },
    {
      'id': '4',
      'title': 'Hoạt động ngoài giờ',
      'className': 'Chủ nhiệm - Lớp 10A2',
      'dueDate': '2024-02-10',
      'status': 'active',
      'submissions': 28,
      'total': 32,
    },
  ];

  // Lọc danh sách bài tập theo tìm kiếm
  List<Map<String, dynamic>> get _filteredAssignments {
    if (_searchQuery.isEmpty) {
      return sampleAssignments;
    }

    final query = _searchQuery.toLowerCase();
    return sampleAssignments.where((assignment) {
      final title = assignment['title'].toString().toLowerCase();
      final className = assignment['className'].toString().toLowerCase();
      return title.contains(query) || className.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Danh sách bài tập'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.md,
              ),
              child: SearchField(
                hintText: 'Tìm kiếm bài tập...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
            ),
            // Danh sách bài tập
            Expanded(child: _buildAssignmentList()),
          ],
        ),
      ),
    );
  }

  /// Danh sách bài tập
  Widget _buildAssignmentList() {
    final filteredList = _filteredAssignments;

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy bài tập',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final assignment = filteredList[index];
        final dueDate = DateTime.parse(assignment['dueDate']);
        final isOverdue =
            dueDate.isBefore(DateTime.now()) &&
            assignment['status'] != 'completed';

        return Card(
          margin: EdgeInsets.only(bottom: DesignSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment['title'],
                            style: DesignTypography.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            assignment['className'],
                            style: DesignTypography.bodySmall.copyWith(
                              color: DesignColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          assignment['status'],
                          isOverdue,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Text(
                        _getStatusLabel(assignment['status'], isOverdue),
                        style: DesignTypography.caption.copyWith(
                          color: _getStatusColor(
                            assignment['status'],
                            isOverdue,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hạn: ${_formatDate(dueDate)}',
                            style: DesignTypography.caption.copyWith(
                              color: isOverdue
                                  ? Colors.red
                                  : DesignColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Text(
                        '${assignment['submissions']}/${assignment['total']}',
                        style: DesignTypography.caption.copyWith(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusLabel(String status, bool isOverdue) {
    if (isOverdue) return 'Quá hạn';
    switch (status) {
      case 'active':
        return 'Đang diễn ra';
      case 'pending':
        return 'Sắp tới';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Quá hạn';
    }
  }

  Color _getStatusColor(String status, bool isOverdue) {
    if (isOverdue) return Colors.red;
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
