"""
Generate comprehensive seed data SQL for AI analytics diversity.
Teacher: Phạm Thị Đào (51e467a2-9033-5e85-b666-164ea075f6c9)
Student: Thái Anh Huy (b3e27ac4-a528-5174-92f8-99a8f273eb84)
"""
import json
from datetime import datetime, timedelta

TEACHER_ID = '51e467a2-9033-5e85-b666-164ea075f6c9'
AH_ID = 'b3e27ac4-a528-5174-92f8-99a8f273eb84'

# Classes where both teacher and student are present
CLASSES = {
    'MMT': '49d85fda-7721-5ba0-9c6a-e1bb3a103124',
    'SQL': 'c92ec820-981f-5f89-ab02-b54f2d9908b9',
    'WEB': 'a71ce1de-3d0b-5121-b707-4ab4c15a7c2b',
    'TTTNN': 'd91b9112-5f49-56c8-bd69-c86ab986ee78',
}

# Students per class (index 0 = Anh Huy, 1-10 = others)
STUDENTS = {
    'MMT': [
        AH_ID,
        'e274bfde-ca3f-56f8-a803-6008bbdbc1e5',  # Bùi Đình Anh
        '2154f53c-8e69-551b-8c0d-5a2457b15fd8',  # Bùi Quang Minh
        '1b091e49-228a-5e43-99ed-47ce336fbdb8',  # Đinh Lê Hoàng
        '091d5c23-dc7e-5a1b-a432-67ea44892d08',  # Đinh Lê Quyền Linh
        '36c67660-c22f-51e5-91d2-be7182bd1b00',  # Hồ Bá Anh
        '3b2baba8-3480-502d-b7bb-2f8d2460c556',  # Hồ Trung Kiên
        '990780aa-e215-576e-80d5-c101fecdb53b',  # Lê Văn Mạnh
        '6d6e6b96-075d-530e-b002-02f9588a8cfb',  # Nguyễn Bỉnh Huy
        '8d5573c0-e908-5f53-97ab-3ed876a76d7b',  # Nguyễn Văn Kiên
        '70f05385-7e11-5227-bb9c-c9443f11d744',  # Trịnh Anh Quân
    ],
    'SQL': [
        AH_ID,
        '24ed3ce4-4a9a-53d4-9b37-1606ac49dee4',  # Đào Duy Phúc
        'c09e4f67-2386-5909-9adb-15bbbf6a191c',  # Đinh Hải Siêu
        '80cf60e4-7ba9-5658-9e3c-b232707d34b7',  # Đoàn Thanh Quang
        '9b0eeae3-2f80-5eaa-96d5-a38394e07308',  # Hồ Đức An
        'c3028369-42b5-5b6d-a5a5-398bf0924d28',  # Lê Đức Hoàng
        '7202124a-5edc-5d49-bee0-e4ede222e3ce',  # Lê Quang Linh
        'c3554670-bf1f-5e0a-9b10-a3f293ff0dea',  # Nguyễn Văn Nam
        '6fca8caa-a02f-57e7-b7d3-e64b23bb1f08',  # Trần Quang Huy
        '30853e7b-2ff9-5efc-a289-c14e17fd8868',  # Trần Quốc Đạt
        'ead3fcc8-68e1-51d9-9efc-012a05fd6968',  # Vi Quang Khải
    ],
    'WEB': [
        AH_ID,
        'c8778c6b-7099-5c09-916c-6b0dabafde41',  # Đặng Bảo Anh
        '557fb48a-b7ee-5086-a3a3-79a5b46f70ab',  # Đặng Doãn Huy Lâm
        'f6d81836-a646-586d-84fa-57cdbe0a6b16',  # Đồng Nguyên Hiếu
        '66b78cb2-bf4a-5729-885e-97e9f8a7e811',  # Hồ Đình Huyên
        'b1aacd92-727f-5a22-a89b-bf65dac3300d',  # Lê Đình Dũng
        '81e257b2-2853-56b1-a03c-dc736c45501d',  # Ngô Kim Huy
        '8085decb-47e9-5c06-a855-b4480596c367',  # Nguyễn Đình Bảo
        '704b369d-adfb-5712-b367-7284af57c57e',  # Nguyễn Lê Đức Bảo
        'ad7fa2ed-1607-5b6c-b037-7c245cbe5f10',  # Trần Chí Thành
        '6b997d4f-faaa-5645-a51d-485d5915e99c',  # Trương Tấn Đạt
    ],
    'TTTNN': [
        AH_ID,
        '1297f674-db1d-5380-ad20-8699125bdf8b',  # Bùi Quốc Tuấn Hưng
        'bcac7810-59dd-5fa2-a0d9-a98e62390d1e',  # Cao Hồng Quân
        '091d5c23-dc7e-5a1b-a432-67ea44892d08',  # Đinh Lê Quyền Linh
        'c01dc4f0-9ca3-5664-9e2c-345b68fc2cf5',  # Lê Đắc Huy
        '7e031865-82d9-556a-abba-1b72f522741b',  # Lê Quốc Đạt
        'b58c71ef-e745-56b4-97f8-3e2b66042ae5',  # Nguyễn Đình Nhân
        '1e5bd030-02be-5be3-b5f5-7573e06c2110',  # Nguyễn Quốc Cường
        '70f05385-7e11-5227-bb9c-c9443f11d744',  # Trịnh Anh Quân
        '7d12f3f8-c815-58fc-8cd1-18192288da88',  # Trịnh Minh Đức
        'd82ae85d-a77a-5435-8c95-1536453d25e2',  # Võ Thành Đạt
    ],
}

# Assignment definitions
# (index, class_key, title, description, total_points, num_mc, mc_pts, num_essay, essay_pts,
#  due_date, status, time_limit, published_at)
ASSIGNMENTS = [
    # MMT Class - 4 assignments
    (1, 'MMT', 'Kiểm tra chương 1: Tổng quan mô hình OSI',
     'Kiểm tra kiến thức về 7 tầng mô hình OSI, chức năng từng tầng và các giao thức liên quan.',
     10.0, 10, 1.0, 0, 0, '2026-01-20 23:59:00+07', 'closed', 20, '2026-01-15 08:00:00+07'),
    (2, 'MMT', 'Bài tập chương 2: Giao thức TCP và UDP',
     'Phân biệt TCP/UDP, phân tích header, three-way handshake, flow control.',
     10.0, 6, 1.0, 1, 4.0, '2026-02-10 23:59:00+07', 'closed', 30, '2026-02-05 08:00:00+07'),
    (3, 'MMT', 'Kiểm tra giữa kỳ: Địa chỉ IP và Subnetting',
     'Tính toán CIDR, chia subnet, xác định network/broadcast address, VLSM.',
     10.0, 8, 0.5, 3, 2.0, '2026-03-05 23:59:00+07', 'closed', 45, '2026-02-28 08:00:00+07'),
    (4, 'MMT', 'Bài tập thực hành: Cấu hình VLAN và Routing cơ bản',
     'Cấu hình VLAN trên switch, inter-VLAN routing, static routing, NAT cơ bản.',
     10.0, 4, 1.0, 2, 3.0, '2026-03-28 23:59:00+07', 'active', 60, '2026-03-22 08:00:00+07'),

    # SQL Class - 3 assignments
    (5, 'SQL', 'Lab 1: Ngôn ngữ DDL và Ràng buộc toàn vẹn',
     'CREATE TABLE, ALTER TABLE, ràng buộc PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, DEFAULT.',
     10.0, 4, 1.0, 2, 3.0, '2026-01-28 23:59:00+07', 'closed', 45, '2026-01-22 08:00:00+07'),
    (6, 'SQL', 'Lab 2: Truy vấn SELECT, JOIN và Hàm Aggregate',
     'INNER/LEFT/RIGHT/FULL JOIN, GROUP BY, HAVING, COUNT, SUM, AVG, subquery.',
     10.0, 6, 1.0, 1, 4.0, '2026-02-18 23:59:00+07', 'closed', 45, '2026-02-12 08:00:00+07'),
    (7, 'SQL', 'Kiểm tra giữa kỳ thực hành SQL Server',
     'Tổng hợp DDL, DML, truy vấn phức tạp, stored procedure cơ bản, transaction.',
     10.0, 8, 0.5, 2, 3.0, '2026-03-10 23:59:00+07', 'closed', 60, '2026-03-04 08:00:00+07'),

    # WEB Class - 3 assignments
    (8, 'WEB', 'Bài tập HTML/CSS cơ bản',
     'Cấu trúc HTML5 semantic, CSS selectors, Flexbox layout, Box model.',
     10.0, 6, 1.0, 1, 4.0, '2026-02-05 23:59:00+07', 'closed', 45, '2026-01-30 08:00:00+07'),
    (9, 'WEB', 'Bài tập JavaScript và DOM manipulation',
     'Biến, hàm, event handling, querySelector, createElement, form validation.',
     10.0, 6, 1.0, 1, 4.0, '2026-02-25 23:59:00+07', 'closed', 45, '2026-02-19 08:00:00+07'),
    (10, 'WEB', 'Kiểm tra giữa kỳ: Lập trình Web tổng hợp',
     'HTML/CSS/JS tổng hợp, Responsive Design, HTTP methods, Client-Server.',
     10.0, 8, 0.5, 2, 3.0, '2026-03-18 23:59:00+07', 'closed', 60, '2026-03-12 08:00:00+07'),

    # TTTNN Class - 2 more assignments (continuing existing MMT content pattern)
    (11, 'TTTNN', 'Bài tập chương 3: Tầng vận chuyển và Socket',
     'TCP/UDP socket, multiplexing/demultiplexing, reliable data transfer, congestion control.',
     10.0, 8, 1.0, 1, 2.0, '2026-03-05 23:59:00+07', 'closed', 30, '2026-02-27 08:00:00+07'),
    (12, 'TTTNN', 'Bài tập chương 4: Tầng ứng dụng (DNS, HTTP, SMTP)',
     'Phân tích DNS resolution, HTTP request/response, email protocols, P2P vs Client-Server.',
     10.0, 8, 1.0, 1, 2.0, '2026-03-28 23:59:00+07', 'active', 30, '2026-03-22 08:00:00+07'),
]

# Submission data per assignment:
# List of (student_index, score, is_late, late_days, time_spent_sec)
# student_index None means student doesn't submit (missing)
SUBMISSIONS_DATA = {
    # MMT A1 (OSI) - all 11 submit
    1: [
        (0, 9.0, False, 0, 780),   # AH: high
        (1, 8.5, False, 0, 650),
        (2, 6.0, False, 0, 900),
        (3, 3.5, False, 0, 1100),  # low
        (4, 7.0, False, 0, 820),
        (5, 9.5, False, 0, 550),   # high
        (6, 4.0, True, 1, 1200),   # late
        (7, 6.5, False, 0, 870),
        (8, 7.5, False, 0, 740),
        (9, 5.0, True, 2, 950),    # late
        (10, 8.0, False, 0, 680),
    ],
    # MMT A2 (TCP/UDP) - 10 submit, student 6 missing
    2: [
        (0, 6.5, False, 0, 1350),   # AH: medium
        (1, 9.0, False, 0, 1100),
        (2, 7.0, False, 0, 1400),
        (3, 2.5, False, 0, 1500),   # low
        (4, 5.5, False, 0, 1300),
        (5, 8.0, False, 0, 1050),
        # student 6 missing
        (7, 6.0, False, 0, 1450),
        (8, 4.5, True, 2, 1600),    # late
        (9, 7.5, False, 0, 1200),
        (10, 9.5, False, 0, 900),
    ],
    # MMT A3 (IP/Subnet) - 9 submit, students 7,9 missing
    3: [
        (0, 4.5, True, 2, 2500),    # AH: low, LATE
        (1, 7.5, False, 0, 2200),
        (2, 5.0, False, 0, 2400),
        (3, 1.5, False, 0, 2700),   # very low
        (4, 6.0, False, 0, 2100),
        (5, 8.5, False, 0, 1900),
        (6, 3.0, True, 3, 2600),    # late
        # student 7 missing
        (8, 5.5, False, 0, 2300),
        # student 9 missing
        (10, 7.0, False, 0, 2050),
    ],
    # MMT A4 (VLAN) - 9 submit, students 3,10 missing
    4: [
        (0, 8.0, False, 0, 2800),   # AH: recovered
        (1, 6.5, False, 0, 3000),
        (2, 8.5, False, 0, 2600),
        # student 3 missing
        (4, 7.0, False, 0, 2900),
        (5, 9.0, False, 0, 2300),
        (6, 5.0, False, 0, 3200),
        (7, 7.5, False, 0, 2700),
        (8, 4.0, True, 2, 3400),    # late
        (9, 6.0, False, 0, 3100),
        # student 10 missing
    ],
    # SQL A1 (DDL) - 10 submit, student 9 missing
    5: [
        (0, 8.5, False, 0, 2100),   # AH: good
        (1, 9.0, False, 0, 1800),   # high
        (2, 6.0, False, 0, 2400),
        (3, 7.5, False, 0, 2200),
        (4, 3.0, False, 0, 2600),   # low
        (5, 5.5, True, 2, 2500),    # late
        (6, 8.0, False, 0, 1900),
        (7, 4.0, False, 0, 2700),
        (8, 7.0, False, 0, 2300),
        # student 9 missing
        (10, 6.5, False, 0, 2200),
    ],
    # SQL A2 (SELECT/JOIN) - 9 submit, students 7,10 missing
    6: [
        (0, 5.5, True, 2, 2400),    # AH: struggled, LATE
        (1, 8.5, False, 0, 2000),
        (2, 7.0, False, 0, 2300),
        (3, 9.0, False, 0, 1800),   # high
        (4, 2.5, False, 0, 2700),   # low
        (5, 6.0, False, 0, 2500),
        (6, 7.5, False, 0, 2100),
        # student 7 missing
        (8, 5.0, False, 0, 2600),
        (9, 8.0, False, 0, 2000),
        # student 10 missing
    ],
    # SQL A3 (Giữa kỳ) - all 11 submit
    7: [
        (0, 7.5, False, 0, 3200),   # AH: decent
        (1, 9.5, False, 0, 2800),   # high
        (2, 4.5, False, 0, 3500),
        (3, 8.0, False, 0, 3000),
        (4, 3.5, True, 2, 3600),    # late, low
        (5, 6.5, False, 0, 3300),
        (6, 9.0, False, 0, 2700),
        (7, 5.0, False, 0, 3400),
        (8, 7.0, False, 0, 3100),
        (9, 6.0, False, 0, 3200),
        (10, 7.5, False, 0, 3000),
    ],
    # WEB A1 (HTML/CSS) - 10 submit, student 10 missing
    8: [
        (0, 9.5, False, 0, 2000),   # AH: very strong
        (1, 8.0, False, 0, 2200),
        (2, 6.5, False, 0, 2400),
        (3, 9.0, False, 0, 1900),   # high
        (4, 3.0, False, 0, 2700),   # low
        (5, 7.0, False, 0, 2300),
        (6, 4.5, True, 2, 2600),    # late
        (7, 6.0, False, 0, 2500),
        (8, 8.5, False, 0, 2100),
        (9, 5.5, False, 0, 2400),
        # student 10 missing
    ],
    # WEB A2 (JS DOM) - 9 submit, students 6,missing
    9: [
        (0, 3.5, True, 2, 2500),    # AH: very weak, LATE
        (1, 7.5, False, 0, 2100),
        (2, 5.0, False, 0, 2400),
        (3, 8.0, False, 0, 2000),
        (4, 2.0, False, 0, 2700),   # low
        (5, 6.5, False, 0, 2300),
        # student 6 missing
        (7, 7.0, False, 0, 2200),
        (8, 9.0, False, 0, 1800),   # high
        (9, 4.5, True, 3, 2600),    # late
        (10, 5.5, False, 0, 2400),
    ],
    # WEB A3 (Giữa kỳ) - 10 submit, student 4 missing
    10: [
        (0, 7.0, False, 0, 3100),   # AH: average
        (1, 8.5, False, 0, 2800),
        (2, 6.0, False, 0, 3300),
        (3, 9.5, False, 0, 2600),   # high
        # student 4 missing
        (5, 5.5, False, 0, 3200),
        (6, 3.5, False, 0, 3500),   # low
        (7, 7.5, False, 0, 3000),
        (8, 8.0, False, 0, 2900),
        (9, 6.5, False, 0, 3100),
        (10, 4.0, True, 2, 3400),   # late
    ],
    # TTTNN A4 (Transport) - 10 submit, student 8 missing
    11: [
        (0, 8.5, False, 0, 1500),   # AH: good
        (1, 6.0, False, 0, 1700),
        (2, 7.5, False, 0, 1600),
        (3, 9.0, False, 0, 1300),   # high
        (4, 4.0, False, 0, 1800),   # low
        (5, 5.5, False, 0, 1750),
        (6, 7.0, False, 0, 1650),
        (7, 8.0, False, 0, 1400),
        # student 8 missing
        (9, 6.5, True, 2, 1800),    # late
        (10, 3.5, False, 0, 1850),
    ],
    # TTTNN A5 (Application) - 8 submit, students 0(AH!),2,6 missing
    12: [
        # AH: NOT SUBMITTED (intentional for diversity)
        (1, 7.0, False, 0, 1600),
        # student 2 missing
        (3, 8.5, False, 0, 1400),
        (4, 5.0, False, 0, 1700),
        (5, 6.5, False, 0, 1650),
        # student 6 missing
        (7, 9.0, False, 0, 1300),   # high
        (8, 7.5, False, 0, 1550),
        (9, 4.0, True, 2, 1800),    # late
        (10, 6.0, False, 0, 1700),
    ],
}

def make_uuid(prefix, a_idx, sub_idx, category):
    """Generate deterministic UUID.
    prefix: 2 hex chars
    a_idx: assignment index 1-12 -> 01-0c
    sub_idx: sub index (question/student) 0-10 -> 00-0a
    category: 'a'=assignment/aq/ws, 'b'=dist/sub, 'c'=analytics
    """
    a_hex = f"{a_idx:02x}"
    s_hex = f"{sub_idx:02x}"
    return f"{prefix}00{a_hex}{s_hex}-0000-4a00-{category}000-000000000001"


def ts(date_str):
    """Format timestamp for SQL."""
    return f"'{date_str}'"


def generate_sql():
    lines = []
    lines.append("-- ============================================================")
    lines.append("-- MIGRATION: Diverse Seed Data for AI Analytics")
    lines.append("-- Date: 2026-04-08")
    lines.append("-- Purpose: Add 12 new assignments with 116 submissions across")
    lines.append("--   4 shared classes between teacher Phạm Thị Đào and student")
    lines.append("--   Thái Anh Huy. Includes diverse scores, late submissions,")
    lines.append("--   missing submissions, skill mastery, and analytics data.")
    lines.append("-- ============================================================")
    lines.append("")
    lines.append("BEGIN;")
    lines.append("")

    # ================================================================
    # SECTION 1: Learning Objectives for WEB subject
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 1: Learning Objectives (WEB subject)")
    lines.append("-- ============================================================")
    web_objectives = [
        ('b0000003-0001-0000-0000-000000000001', 'WEB', 'WEB.ROOT', 'Kiến thức tổng quan Cơ sở lập trình web', None, None),
        ('b0000003-0001-0001-0000-000000000001', 'WEB', 'WEB.1', 'Cấu trúc HTML và semantic tags', 2, 'b0000003-0001-0000-0000-000000000001'),
        ('b0000003-0001-0002-0000-000000000001', 'WEB', 'WEB.2', 'Thiết kế CSS Layout (Flexbox, Grid)', 2, 'b0000003-0001-0000-0000-000000000001'),
        ('b0000003-0001-0003-0000-000000000001', 'WEB', 'WEB.3', 'JavaScript DOM manipulation', 3, 'b0000003-0001-0000-0000-000000000001'),
        ('b0000003-0001-0004-0000-000000000001', 'WEB', 'WEB.4', 'Responsive Design và Media Queries', 2, 'b0000003-0001-0000-0000-000000000001'),
        ('b0000003-0001-0005-0000-000000000001', 'WEB', 'WEB.5', 'HTTP, Client-Server và Form handling', 3, 'b0000003-0001-0000-0000-000000000001'),
    ]
    lines.append("INSERT INTO learning_objectives (id, subject_code, code, description, difficulty, parent_id, metadata, created_at) VALUES")
    obj_vals = []
    for oid, sc, code, desc, diff, pid in web_objectives:
        diff_str = str(diff) if diff else 'NULL'
        pid_str = f"'{pid}'" if pid else 'NULL'
        meta = "'{\"level\": \"root\"}'::jsonb" if 'ROOT' in code else 'NULL'
        obj_vals.append(f"  ('{oid}', '{sc}', '{code}', '{desc}', {diff_str}, {pid_str}, {meta}, '2025-12-31 17:00:00+00')")
    lines.append(",\n".join(obj_vals) + ";")
    lines.append("")

    # ================================================================
    # SECTION 2: Assignments
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 2: New Assignments (12 total)")
    lines.append("-- ============================================================")
    lines.append("INSERT INTO assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at, default_shuffle_questions, default_shuffle_choices) VALUES")
    a_vals = []
    for a in ASSIGNMENTS:
        idx, class_key, title, desc, pts, _, _, _, _, due, status, tl, pub = a
        a_id = make_uuid('dd', idx, 0, 'a')
        class_id = CLASSES[class_key]
        a_vals.append(
            f"  ('{a_id}', '{class_id}', '{TEACHER_ID}',\n"
            f"   '{title}', '{desc}',\n"
            f"   true, {ts(pub)}, {pts:.2f}, {ts(pub)}, {ts(pub)}, true, true)"
        )
    lines.append(",\n".join(a_vals) + ";")
    lines.append("")

    # ================================================================
    # SECTION 3: Assignment Distributions
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 3: Assignment Distributions (12 total)")
    lines.append("-- ============================================================")
    lines.append("INSERT INTO assignment_distributions (id, assignment_id, distribution_type, class_id, due_at, time_limit_minutes, allow_late, late_policy, created_at, status, settings) VALUES")
    d_vals = []
    for a in ASSIGNMENTS:
        idx, class_key, title, desc, pts, _, _, _, _, due, status, tl, pub = a
        a_id = make_uuid('dd', idx, 0, 'a')
        d_id = make_uuid('dd', idx, 0, 'b')
        class_id = CLASSES[class_key]
        late_policy = json.dumps({"penalty_per_day_percent": 10})
        settings = json.dumps({"shuffle_choices": True, "shuffle_questions": True, "show_score_immediately": True})
        d_vals.append(
            f"  ('{d_id}', '{a_id}', 'class', '{class_id}',\n"
            f"   {ts(due)}, {tl}, true,\n"
            f"   '{late_policy}'::jsonb, {ts(pub)}, '{status}',\n"
            f"   '{settings}'::jsonb)"
        )
    lines.append(",\n".join(d_vals) + ";")
    lines.append("")

    # ================================================================
    # SECTION 4: Assignment Questions
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 4: Assignment Questions")
    lines.append("-- ============================================================")
    lines.append("INSERT INTO assignment_questions (id, assignment_id, question_id, points, order_idx) VALUES")
    q_vals = []
    for a in ASSIGNMENTS:
        idx, class_key, title, desc, pts, num_mc, mc_pts, num_essay, essay_pts, *_ = a
        a_id = make_uuid('dd', idx, 0, 'a')
        q_order = 1
        for i in range(num_mc):
            q_id = make_uuid('ee', idx, q_order, 'a')
            q_vals.append(f"  ('{q_id}', '{a_id}', NULL, {mc_pts:.2f}, {q_order})")
            q_order += 1
        for i in range(num_essay):
            q_id = make_uuid('ee', idx, q_order, 'a')
            q_vals.append(f"  ('{q_id}', '{a_id}', NULL, {essay_pts:.2f}, {q_order})")
            q_order += 1
    lines.append(",\n".join(q_vals) + ";")
    lines.append("")

    # ================================================================
    # SECTION 5: Work Sessions + Submissions
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 5: Work Sessions and Submissions")
    lines.append("-- ============================================================")

    for a in ASSIGNMENTS:
        idx, class_key, title, desc, pts, _, _, _, _, due_str, status, tl, pub = a
        a_id = make_uuid('dd', idx, 0, 'a')
        d_id = make_uuid('dd', idx, 0, 'b')
        students = STUDENTS[class_key]
        subs = SUBMISSIONS_DATA[idx]

        lines.append(f"")
        lines.append(f"-- Assignment {idx}: {title} ({class_key})")

        # Parse due date for offset calculations
        # Due dates are like '2026-01-20 23:59:00+07'
        due_base = due_str.replace('+07', '')

        # Work Sessions
        lines.append(f"INSERT INTO work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at) VALUES")
        ws_vals = []
        for s_idx, score, is_late, late_days, time_spent in subs:
            student_id = students[s_idx]
            ws_id = make_uuid('ff', idx, s_idx, 'a')

            if is_late:
                sub_dt_str = _offset_date(due_str, late_days)
            else:
                sub_dt_str = _offset_date(due_str, -1)  # 1 day before due

            start_dt_str = _offset_seconds(sub_dt_str, -time_spent)

            ws_vals.append(
                f"  ('{ws_id}', '{d_id}', '{a_id}', '{student_id}',\n"
                f"   '{start_dt_str}', '{sub_dt_str}', 1, 'submitted', {time_spent},\n"
                f"   '{sub_dt_str}', '{sub_dt_str}')"
            )
        lines.append(",\n".join(ws_vals) + ";")

        # Submissions
        lines.append(f"INSERT INTO submissions (id, assignment_id, student_id, session_id, submitted_at, is_late, total_score, ai_graded, created_at, updated_at, is_voided, assignment_distribution_id) VALUES")
        sub_vals = []
        for s_idx, score, is_late, late_days, time_spent in subs:
            student_id = students[s_idx]
            sub_id = make_uuid('ff', idx, s_idx, 'b')
            ws_id = make_uuid('ff', idx, s_idx, 'a')

            if is_late:
                sub_dt_str = _offset_date(due_str, late_days)
            else:
                sub_dt_str = _offset_date(due_str, -1)

            is_late_str = 'true' if is_late else 'false'

            sub_vals.append(
                f"  ('{sub_id}', '{a_id}', '{student_id}', '{ws_id}',\n"
                f"   '{sub_dt_str}', {is_late_str}, {score:.2f}, true,\n"
                f"   '{sub_dt_str}', '{sub_dt_str}', false, '{d_id}')"
            )
        lines.append(",\n".join(sub_vals) + ";")

    lines.append("")

    # ================================================================
    # SECTION 6: Submission Analytics (Anh Huy only)
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 6: Submission Analytics (Anh Huy)")
    lines.append("-- ============================================================")

    ah_analytics_data = {
        1: {"accuracy_by_tag": {"osi": 0.9, "network_layers": 0.85}, "time_per_question": {"q1": 45, "q2": 60, "q3": 55, "q4": 80, "q5": 70}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.95}, {"difficulty": 3, "score": 0.85}]},
        2: {"accuracy_by_tag": {"tcp": 0.55, "udp": 0.7, "transport": 0.6}, "time_per_question": {"q1": 120, "q2": 90, "q3": 150, "q4": 180}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.7}, {"difficulty": 3, "score": 0.55}]},
        3: {"accuracy_by_tag": {"ip_addressing": 0.4, "subnetting": 0.3, "cidr": 0.5}, "time_per_question": {"q1": 200, "q2": 250, "q3": 300, "q4": 180}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.5}, {"difficulty": 3, "score": 0.35}, {"difficulty": 4, "score": 0.3}]},
        4: {"accuracy_by_tag": {"vlan": 0.8, "routing": 0.75, "nat": 0.85}, "time_per_question": {"q1": 300, "q2": 350, "q3": 280, "q4": 400}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.85}, {"difficulty": 3, "score": 0.75}]},
        5: {"accuracy_by_tag": {"ddl": 0.9, "constraints": 0.8, "alter": 0.85}, "time_per_question": {"q1": 200, "q2": 250, "q3": 180, "q4": 300}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.8}]},
        6: {"accuracy_by_tag": {"select": 0.6, "join": 0.4, "aggregate": 0.55}, "time_per_question": {"q1": 180, "q2": 250, "q3": 300, "q4": 280}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.6}, {"difficulty": 3, "score": 0.45}]},
        7: {"accuracy_by_tag": {"ddl": 0.8, "dml": 0.75, "stored_proc": 0.7, "transaction": 0.65}, "time_per_question": {"q1": 250, "q2": 280, "q3": 300, "q4": 320, "q5": 350}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.8}, {"difficulty": 3, "score": 0.7}]},
        8: {"accuracy_by_tag": {"html": 0.95, "css": 0.9, "semantic": 0.95}, "time_per_question": {"q1": 150, "q2": 180, "q3": 200, "q4": 160}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.95}, {"difficulty": 3, "score": 0.9}]},
        9: {"accuracy_by_tag": {"javascript": 0.3, "dom": 0.25, "events": 0.4, "forms": 0.35}, "time_per_question": {"q1": 300, "q2": 350, "q3": 280, "q4": 400}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.4}, {"difficulty": 3, "score": 0.25}]},
        10: {"accuracy_by_tag": {"html_css": 0.8, "javascript": 0.6, "responsive": 0.7, "http": 0.65}, "time_per_question": {"q1": 200, "q2": 250, "q3": 280, "q4": 300, "q5": 320}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.75}, {"difficulty": 3, "score": 0.65}]},
        11: {"accuracy_by_tag": {"transport": 0.85, "socket": 0.8, "congestion": 0.9}, "time_per_question": {"q1": 100, "q2": 120, "q3": 150, "q4": 130}, "difficulty_vs_score": [{"difficulty": 2, "score": 0.9}, {"difficulty": 3, "score": 0.8}]},
        # 12: AH doesn't submit this one
    }

    lines.append("INSERT INTO submission_analytics (id, submission_id, metrics, created_at) VALUES")
    sa_vals = []
    for a_idx, metrics in ah_analytics_data.items():
        sa_id = make_uuid('ff', a_idx, 0, 'c')
        sub_id = make_uuid('ff', a_idx, 0, 'b')
        a_def = ASSIGNMENTS[a_idx - 1]
        due_str = a_def[9]
        sub_dt = _offset_date(due_str, -1)
        if a_idx in [3, 6, 9]:  # late ones
            late_days_map = {3: 2, 6: 2, 9: 2}
            sub_dt = _offset_date(due_str, late_days_map[a_idx])
        created = _offset_date(sub_dt, 1)  # analytics created 1 day after submission
        sa_vals.append(
            f"  ('{sa_id}', '{sub_id}',\n"
            f"   '{json.dumps(metrics)}'::jsonb,\n"
            f"   '{created}')"
        )
    lines.append(",\n".join(sa_vals) + ";")
    lines.append("")

    # ================================================================
    # SECTION 7: Student Skill Mastery
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 7: Student Skill Mastery")
    lines.append("-- ============================================================")
    lines.append("-- Add SQL and WEB skills for Anh Huy")
    lines.append("-- Update MMT skills with more attempts")

    # Anh Huy - SQL skills
    ah_sql_skills = [
        ('b0000002-0001-0001-0000-000000000001', 0.82, 10, 8),  # SQL.1 DDL - strong
        ('b0000002-0001-0002-0000-000000000001', 0.70, 8, 6),   # SQL.2 Constraints - good
        ('b0000002-0001-0003-0000-000000000001', 0.48, 12, 5),  # SQL.3 JOIN/Aggregate - WEAK
        ('b0000002-0001-0004-0000-000000000001', 0.62, 6, 4),   # SQL.4 StoredProc - medium
        ('b0000002-0001-0005-0000-000000000001', 0.58, 8, 5),   # SQL.5 INDEX/Transaction - medium
    ]

    # Anh Huy - WEB skills
    ah_web_skills = [
        ('b0000003-0001-0001-0000-000000000001', 0.92, 10, 9),  # WEB.1 HTML - very strong
        ('b0000003-0001-0002-0000-000000000001', 0.88, 8, 7),   # WEB.2 CSS - strong
        ('b0000003-0001-0003-0000-000000000001', 0.32, 10, 3),  # WEB.3 JS DOM - VERY WEAK
        ('b0000003-0001-0004-0000-000000000001', 0.68, 6, 4),   # WEB.4 Responsive - medium
        ('b0000003-0001-0005-0000-000000000001', 0.60, 8, 5),   # WEB.5 HTTP - medium
    ]

    lines.append("INSERT INTO student_skill_mastery (student_id, objective_id, mastery_level, attempts, correct, last_updated) VALUES")
    sm_vals = []
    for obj_id, mastery, attempts, correct in ah_sql_skills:
        sm_vals.append(f"  ('{AH_ID}', '{obj_id}', {mastery:.2f}, {attempts}, {correct}, NOW())")
    for obj_id, mastery, attempts, correct in ah_web_skills:
        sm_vals.append(f"  ('{AH_ID}', '{obj_id}', {mastery:.2f}, {attempts}, {correct}, NOW())")
    lines.append(",\n".join(sm_vals) + ";")
    lines.append("")

    # Update existing MMT skills with more attempts
    lines.append("-- Update Anh Huy's existing MMT skills (more attempts from new assignments)")
    mmt_updates = [
        ('b0000001-0001-0001-0000-000000000001', 0.78, 14, 11),  # MMT.1 OSI -> improved
        ('b0000001-0001-0002-0000-000000000001', 0.60, 12, 7),   # MMT.2 TCP/UDP -> slightly worse
        ('b0000001-0001-0003-0000-000000000001', 0.42, 16, 7),   # MMT.3 IP/Subnet -> still weak
        ('b0000001-0001-0004-0000-000000000001', 0.80, 8, 6),    # MMT.4 Devices -> improved
        ('b0000001-0001-0005-0000-000000000001', 0.65, 10, 7),   # MMT.5 Services -> improved
        ('b0000001-0001-0006-0000-000000000001', 0.72, 8, 6),    # MMT.6 VLAN -> improved
    ]
    for obj_id, mastery, attempts, correct in mmt_updates:
        lines.append(
            f"UPDATE student_skill_mastery SET mastery_level = {mastery:.2f}, attempts = {attempts}, "
            f"correct = {correct}, last_updated = NOW() "
            f"WHERE student_id = '{AH_ID}' AND objective_id = '{obj_id}';"
        )
    lines.append("")

    # Add skill mastery for some other students (diversity for class-level analytics)
    lines.append("-- Skill mastery for other students (diversity)")
    other_skills = []

    # MMT students skills (pick 5 students from MMT class)
    mmt_other_students = STUDENTS['MMT'][1:6]
    mmt_objectives = [
        'b0000001-0001-0001-0000-000000000001',
        'b0000001-0001-0002-0000-000000000001',
        'b0000001-0001-0003-0000-000000000001',
    ]
    mmt_student_skills = [
        # student1 (Bùi Đình Anh) - all-rounder
        [(0.85, 12, 10), (0.75, 10, 8), (0.70, 14, 10)],
        # student2 (Bùi Quang Minh) - average
        [(0.60, 10, 6), (0.55, 8, 4), (0.45, 12, 5)],
        # student3 (Đinh Lê Hoàng) - weak
        [(0.35, 8, 3), (0.30, 6, 2), (0.20, 10, 2)],
        # student4 (Đinh Lê Quyền Linh) - medium
        [(0.70, 10, 7), (0.60, 8, 5), (0.55, 12, 7)],
        # student5 (Hồ Bá Anh) - strong
        [(0.90, 12, 11), (0.85, 10, 9), (0.80, 14, 11)],
    ]
    for s_i, student_id in enumerate(mmt_other_students):
        for o_i, obj_id in enumerate(mmt_objectives):
            m, a, c = mmt_student_skills[s_i][o_i]
            other_skills.append(f"  ('{student_id}', '{obj_id}', {m:.2f}, {a}, {c}, NOW())")

    # SQL students skills (pick 3)
    sql_other_students = STUDENTS['SQL'][1:4]
    sql_objectives = [
        'b0000002-0001-0001-0000-000000000001',
        'b0000002-0001-0003-0000-000000000001',
    ]
    sql_student_skills = [
        [(0.88, 10, 9), (0.80, 12, 10)],   # Đào Duy Phúc - strong
        [(0.55, 8, 4), (0.50, 10, 5)],      # Đinh Hải Siêu - medium
        [(0.78, 10, 8), (0.72, 12, 9)],     # Đoàn Thanh Quang - good
    ]
    for s_i, student_id in enumerate(sql_other_students):
        for o_i, obj_id in enumerate(sql_objectives):
            m, a, c = sql_student_skills[s_i][o_i]
            other_skills.append(f"  ('{student_id}', '{obj_id}', {m:.2f}, {a}, {c}, NOW())")

    # WEB students skills (pick 3)
    web_other_students = STUDENTS['WEB'][1:4]
    web_objectives = [
        'b0000003-0001-0001-0000-000000000001',
        'b0000003-0001-0003-0000-000000000001',
    ]
    web_student_skills = [
        [(0.82, 10, 8), (0.70, 12, 8)],    # Đặng Bảo Anh - good
        [(0.55, 8, 4), (0.45, 10, 5)],     # Đặng Doãn Huy Lâm - medium
        [(0.90, 10, 9), (0.85, 12, 10)],   # Đồng Nguyên Hiếu - strong
    ]
    for s_i, student_id in enumerate(web_other_students):
        for o_i, obj_id in enumerate(web_objectives):
            m, a, c = web_student_skills[s_i][o_i]
            other_skills.append(f"  ('{student_id}', '{obj_id}', {m:.2f}, {a}, {c}, NOW())")

    if other_skills:
        lines.append("INSERT INTO student_skill_mastery (student_id, objective_id, mastery_level, attempts, correct, last_updated) VALUES")
        lines.append(",\n".join(other_skills) + "\nON CONFLICT (student_id, objective_id) DO UPDATE SET mastery_level = EXCLUDED.mastery_level, attempts = EXCLUDED.attempts, correct = EXCLUDED.correct, last_updated = NOW();")
    lines.append("")

    # ================================================================
    # SECTION 8: Teacher Notes
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 8: Additional Teacher Notes")
    lines.append("-- ============================================================")
    notes = [
        ("Cần hỗ trợ thêm phần Subnetting, sinh viên hay nhầm lẫn khi chia mạng con.", True),
        ("Sinh viên tiến bộ rõ rệt ở phần VLAN sau khi được hướng dẫn thêm.", True),
        ("JavaScript DOM là điểm yếu lớn nhất, cần ôn lại từ cơ bản.", True),
        ("SQL JOIN cần thực hành thêm, khuyến khích làm thêm bài tập ngoài giờ.", False),
    ]
    lines.append("INSERT INTO teacher_notes (id, teacher_id, student_id, content, is_private, created_at) VALUES")
    tn_vals = []
    for i, (content, is_private) in enumerate(notes):
        tn_id = make_uuid('aa', 99, i, 'a')
        date_offset = f"2026-03-{15 + i * 5:02d} 08:00:00+00"
        priv = 'true' if is_private else 'false'
        tn_vals.append(f"  ('{tn_id}', '{TEACHER_ID}', '{AH_ID}', '{content}', {priv}, '{date_offset}')")
    lines.append(",\n".join(tn_vals) + ";")
    lines.append("")

    # ================================================================
    # SECTION 9: AI Recommendations
    # ================================================================
    lines.append("-- ============================================================")
    lines.append("-- SECTION 9: AI Recommendations for Teacher")
    lines.append("-- ============================================================")
    recommendations = [
        ('individual', 2, 'Cần ôn tập Subnetting', 'Sinh viên Thái Anh Huy có mastery thấp ở kỹ năng IP/Subnet (42%). Cần thêm bài tập thực hành chia mạng con.'),
        ('individual', 3, 'Hỗ trợ JavaScript DOM', 'Kỹ năng JS DOM manipulation chỉ đạt 32%. Đề xuất cho báo cáo cá nhân và hướng dẫn thêm.'),
        ('individual', 1, 'Điểm mạnh HTML/CSS', 'Sinh viên nắm vững HTML semantic (92%) và CSS Layout (88%). Có thể giao bài nâng cao.'),
    ]
    lines.append("INSERT INTO ai_recommendations (id, teacher_id, class_id, student_id, type, priority, title, description, resources, dismissed, created_at) VALUES")
    rec_vals = []
    rec_classes = [CLASSES['MMT'], CLASSES['WEB'], CLASSES['WEB']]
    for i, (rtype, priority, title, desc) in enumerate(recommendations):
        rec_id = make_uuid('bb', 99, i, 'a')
        class_id = rec_classes[i]
        resources = json.dumps({"videos": [], "documents": [], "exercises": []})
        date = f"2026-04-{1 + i:02d} 08:00:00+00"
        rec_vals.append(
            f"  ('{rec_id}', '{TEACHER_ID}', '{class_id}', '{AH_ID}',\n"
            f"   '{rtype}', {priority}, '{title}',\n"
            f"   '{desc}',\n"
            f"   '{resources}'::jsonb, false, '{date}')"
        )
    lines.append(",\n".join(rec_vals) + ";")
    lines.append("")

    # NOTE: Section 10 (question_objectives) removed - assignment_questions IDs
    # cannot be used as question_id FK in question_objectives table

    lines.append("COMMIT;")
    lines.append("")
    lines.append("-- ============================================================")
    lines.append("-- END OF MIGRATION")
    lines.append("-- Total: 12 assignments, ~116 submissions, 6 WEB learning")
    lines.append("-- objectives, 10 SQL+WEB skill mastery records for Anh Huy,")
    lines.append("-- 11 submission analytics, 4 teacher notes, 3 AI recommendations")
    lines.append("-- ============================================================")

    return "\n".join(lines)


def _offset_date(date_str, days):
    """Offset a date string by N days. Positive = future, negative = past."""
    # Parse: '2026-01-20 23:59:00+07'
    base = date_str.replace('+07', '').strip().strip("'")
    dt = datetime.strptime(base, '%Y-%m-%d %H:%M:%S')
    dt += timedelta(days=days)
    return dt.strftime('%Y-%m-%d %H:%M:%S+07')


def _offset_seconds(date_str, seconds):
    """Offset a date string by N seconds."""
    base = date_str.replace('+07', '').strip().strip("'")
    dt = datetime.strptime(base, '%Y-%m-%d %H:%M:%S')
    dt += timedelta(seconds=seconds)
    return dt.strftime('%Y-%m-%d %H:%M:%S+07')


if __name__ == '__main__':
    sql = generate_sql()
    output_path = 'd:/code/Flutter_Android/Flutter_Android/AI_LMS_PRD/seed_data/08_analytics_diversity_seed.sql'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(sql)
    print(f"Generated SQL migration: {output_path}")
    # Count lines and stats
    total_lines = sql.count('\n')
    insert_count = sql.count('INSERT INTO')
    print(f"Total lines: {total_lines}")
    print(f"INSERT statements: {insert_count}")
