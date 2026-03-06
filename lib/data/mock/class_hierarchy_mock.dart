import 'package:ai_mls/domain/entities/recipient_tree_node.dart';

final mockClassHierarchy = <ClassNode>[
  ClassNode(
    id: 'c_12a1',
    name: 'Lớp 12A1',
    totalStudents: 35,
    groups: [
      GroupNode(
        id: 'g_12a1_1',
        name: 'Nhóm 1: HS Giỏi',
        students: [
          StudentNode(id: 's_001', name: 'Nguyễn Văn An', score: 9.5),
          StudentNode(id: 's_002', name: 'Trần Thị Bình', score: 9.2),
          StudentNode(id: 's_003', name: 'Lê Văn Cường', score: 9.0),
        ],
      ),
      GroupNode(
        id: 'g_12a1_2',
        name: 'Nhóm 2: Trung bình',
        students: List.generate(
          20,
          (i) =>
              StudentNode(id: 's_mid_$i', name: 'Học sinh TB $i', score: 6.5),
        ),
      ),
      GroupNode(
        id: 'g_12a1_3',
        name: 'Nhóm 3: Cần kèm cặp',
        students: [
          StudentNode(id: 's_004', name: 'Hoàng Văn D', score: 4.5),
          StudentNode(id: 's_005', name: 'Đỗ Thị E', score: 4.8),
          StudentNode(id: 's_006', name: 'Phạm Minh F', score: 5.0),
          StudentNode(id: 's_007', name: 'Lý Quốc G', score: 3.5),
          StudentNode(id: 's_008', name: 'Vũ Hải H', score: 4.0),
        ],
      ),
    ],
    independentStudents: [
      const StudentNode(
        id: 's_ind_1',
        name: 'Nguyễn Văn B',
        note: 'Cần hỗ trợ',
      ),
    ],
  ),
  ClassNode(
    id: 'c_12a2',
    name: 'Lớp 12A2',
    totalStudents: 32,
    groups: [
      GroupNode(
        id: 'g_12a2_1',
        name: 'Nhóm 1: Tự nhiên',
        students: List.generate(
          15,
          (i) => StudentNode(id: 's_tn_$i', name: 'HS Tự Nhiên $i'),
        ),
      ),
      GroupNode(
        id: 'g_12a2_2',
        name: 'Nhóm 2: Xã hội',
        students: List.generate(
          17,
          (i) => StudentNode(id: 's_xh_$i', name: 'HS Xã Hội $i'),
        ),
      ),
    ],
    independentStudents: [const StudentNode(id: 's_ind_2', name: 'Trần Văn C')],
  ),
  const ClassNode(
    id: 'c_12a3',
    name: 'Lớp 12A3',
    totalStudents: 40,
    groups: [],
    independentStudents: [],
  ),
  const ClassNode(
    id: 'c_11b1',
    name: 'Lớp 11B1',
    totalStudents: 38,
    groups: [],
    independentStudents: [],
  ),
  ClassNode(
    id: 'inter_class_root',
    name: 'Nhóm liên thông',
    totalStudents: 15,
    groups: [
      GroupNode(
        id: 'g_inter_1',
        name: 'Đội tuyển Olympic Toán',
        students: [
          StudentNode(id: 's_001', name: 'Nguyễn Văn An', score: 9.5),
          StudentNode(id: 's_tn_1', name: 'HS Tự Nhiên 1'),
          StudentNode(id: 's_ind_2', name: 'Trần Văn C'),
        ],
      ),
      GroupNode(
        id: 'g_inter_2',
        name: 'CLB Tiếng Anh',
        students: [
          StudentNode(id: 's_002', name: 'Trần Thị Bình', score: 9.2),
          StudentNode(id: 's_xh_2', name: 'HS Xã Hội 2'),
        ],
      ),
    ],
    independentStudents: [],
  ),
];
