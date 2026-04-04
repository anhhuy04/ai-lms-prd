#!/usr/bin/env python3
"""
Generate comprehensive seed SQL for ALL 29 public tables.
Reads student/teacher data from .md files in seed_data/
Outputs: seed_data/06_full_seed.sql
"""
import uuid
import json
import re
import random
import hashlib
from datetime import datetime, timedelta

random.seed(42)  # Reproducible

# ============================================================
# CONSTANTS
# ============================================================
SCHOOL_NAME = "Trường Đại học Sư phạm Kỹ thuật Vinh"
SCHOOL_ID = "a0000001-0000-0000-0000-000000000001"
# Dates: Jan-Mar 2026
BASE_DATE = datetime(2026, 1, 5, 8, 0, 0)  # Start of HK2

def make_uuid(namespace: str) -> str:
    """Deterministic UUID from string."""
    return str(uuid.uuid5(uuid.NAMESPACE_DNS, f"seed.{namespace}"))

def sql_escape(s: str) -> str:
    if s is None:
        return "NULL"
    return "'" + s.replace("'", "''") + "'"

def json_escape(obj) -> str:
    return sql_escape(json.dumps(obj, ensure_ascii=False))

# ============================================================
# PARSE .md FILES
# ============================================================
def parse_students_md(filepath: str):
    """Parse 02_students.md → list of dicts."""
    students = []
    current_class = None
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            # Detect class header
            m = re.match(r'^## (DH\w+)', line)
            if m:
                current_class = m.group(1)
                continue
            # Parse student row
            if line.startswith('|') and not line.startswith('|---') and not line.startswith('| STT'):
                parts = [p.strip() for p in line.split('|')]
                parts = [p for p in parts if p]
                if len(parts) >= 6:
                    try:
                        int(parts[0])  # STT
                    except:
                        continue
                    student_code = parts[1]
                    enrollment_class = parts[2]
                    full_name = parts[3]
                    dob = parts[4] if parts[4] != '(không có)' else None
                    email = parts[5]
                    students.append({
                        'student_code': student_code,
                        'enrollment_class': enrollment_class,
                        'full_name': full_name,
                        'dob': dob,
                        'email': email,
                        'section': current_class,
                    })
    return students

def parse_class_members_md(filepath: str):
    """Parse 04_class_members.md → dict: class_label -> list of student_codes."""
    classes = {}
    current_label = None
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            m = re.match(r'^## Lớp (\d+):', line)
            if m:
                current_label = int(m.group(1))
                classes[current_label] = []
                continue
            if current_label and line.startswith('|') and not line.startswith('|---') and not line.startswith('| STT'):
                parts = [p.strip() for p in line.split('|')]
                parts = [p for p in parts if p]
                if len(parts) >= 4:
                    try:
                        int(parts[0])
                        classes[current_label].append({
                            'student_code': parts[1],
                            'enrollment_class': parts[2],
                            'full_name': parts[3],
                        })
                    except:
                        pass
    return classes


# ============================================================
# DATA
# ============================================================
TEACHERS = [
    {"name": "Nguyễn Thị Lan Anh", "email": "anhntl.skv@gmail.com", "phone": "0919776383", "degree": "ThS", "address": "Quỳnh Lưu, Nghệ An"},
    {"name": "Phạm Thị Thanh Bình", "email": "binmc31383@gmail.com", "phone": "0913272335", "degree": "ThS", "address": "Hưng Nguyên, Nghệ An"},
    {"name": "Phạm Thị Đào", "email": "phamthidaoskv@gmail.com", "phone": "0399162789", "degree": "ThS, Chủ tịch CĐBP", "address": "Nghi Lộc, Nghệ An"},
    {"name": "Trần Thị Gia", "email": "tranthigia40@gmail.com", "phone": "0963143666", "degree": "ThS", "address": "Yên Định, Thanh Hóa"},
    {"name": "Phan Việt Đức", "email": "phanvietducktv@gmail.com", "phone": "0904597555", "degree": "GV kiêm nhiệm", "address": "Đức Thọ, Hà Tĩnh"},
    {"name": "Trần Bình Giang", "email": "binhgiangktv@gmai.com", "phone": "0944330567", "degree": "ThS", "address": "Quỳnh Lưu, Nghệ An"},
    {"name": "Nguyễn Quốc Khánh", "email": "khanh.nguyen.224.229@gmail.com", "phone": "0946433919", "degree": "ThS", "address": "Thanh Chương, Nghệ An"},
    {"name": "Vũ Thị Thu Hiền", "email": "thuhienktv@gmail.com", "phone": "0904315557", "degree": "ThS, Phó Trưởng Khoa", "address": "Vinh, Nghệ An"},
    {"name": "Võ Thị Kim Hoa", "email": "ngaymaitroivanxanh@gmail.com", "phone": "0975640641", "degree": "ThS", "address": "Nghi Lộc, Nghệ An"},
    {"name": "Lê Thị Ánh Hồng", "email": "hongskv@gmail.com", "phone": "0968611850", "degree": "ThS", "address": "Hương Khê, Hà Tĩnh"},
    {"name": "Nguyễn Thị Phương Thủy", "email": "phuongthuyskv@gmail.com", "phone": "0904295567", "degree": "ThS", "address": "Anh Sơn, Nghệ An"},
    {"name": "Hồ Ngọc Vinh", "email": "hongocvinh@gmail.com", "phone": "0968134666", "degree": "TS, Trưởng Khoa", "address": "Quỳnh Lưu, Nghệ An"},
    {"name": "Lê Thị Linh", "email": "lelinhktv@gmail.com", "phone": "0989458282", "degree": "ThS", "address": "Quảng Ninh, Quảng Bình"},
    {"name": "Nguyễn Thị Quỳnh Vinh", "email": "vinhnq82@gmail.com", "phone": "0964632567", "degree": "ThS", "address": "Vinh, Nghệ An"},
]

# 12 Classes from 03_classes.md
CLASSES_DEF = [
    {"idx": 1, "code": "MMT(224)_01/K18A1", "name": "Mạng máy tính", "subject": "Mạng máy tính", "teacher_idx": 2, "year": "2024-2025", "semester": "HK2", "room": "A2.310", "schedule": "Thứ 6, tiết 3,4", "start": "2024-12-30", "end": "2025-05-04", "type": "LT"},
    {"idx": 2, "code": "MMT(225)_01/K19A1", "name": "Mạng máy tính", "subject": "Mạng máy tính", "teacher_idx": 2, "year": "2025-2026", "semester": "HK2", "room": "A2.208", "schedule": "Thứ 2, tiết 3,4", "start": "2026-01-05", "end": "2026-05-10", "type": "LT"},
    {"idx": 3, "code": "MMT(225)_03/K19A2", "name": "Mạng máy tính", "subject": "Mạng máy tính", "teacher_idx": 2, "year": "2025-2026", "semester": "HK2", "room": "A2.411", "schedule": "Thứ 6, tiết 8,9", "start": "2025-12-22", "end": "2026-04-26", "type": "LT"},
    {"idx": 4, "code": "TCB(125)_17/DTCNK20A1", "name": "Tin học cơ bản", "subject": "Tin học cơ bản", "teacher_idx": 2, "year": "2025-2026", "semester": "HK1", "room": "A2.404", "schedule": "Thứ 6, tiết 1,2,3", "start": "2025-09-08", "end": "2025-12-21", "type": "LT"},
    {"idx": 5, "code": "PTUDW1(123)_04_TH/K17A2", "name": "Phát triển ứng dụng Web 1 TH", "subject": "Phát triển ứng dụng Web 1", "teacher_idx": 2, "year": "2023-2024", "semester": "HK1", "room": "A3.204", "schedule": "Xưởng", "start": "2023-10-16", "end": "2023-11-26", "type": "TH"},
    {"idx": 6, "code": "SQLSERVER(123)_01_TH/K17A1", "name": "Hệ quản trị CSDL SQL Server TH", "subject": "Hệ quản trị CSDL SQL Server", "teacher_idx": 2, "year": "2023-2024", "semester": "HK1", "room": "A3.204", "schedule": "Xưởng", "start": "2023-09-25", "end": "2023-10-14", "type": "TH"},
    {"idx": 7, "code": "PTUDW1(125)_03_TH/K19A2", "name": "Phát triển ứng dụng Web 1 TH", "subject": "Phát triển ứng dụng Web 1", "teacher_idx": 0, "year": "2025-2026", "semester": "HK1", "room": "A3.402", "schedule": "Xưởng", "start": "2025-09-01", "end": "2025-10-12", "type": "TH"},
    {"idx": 8, "code": "SQLSERVER(125)_03_TH/K19A2_A", "name": "Hệ quản trị CSDL SQL Server TH (đợt 1)", "subject": "Hệ quản trị CSDL SQL Server", "teacher_idx": 2, "year": "2025-2026", "semester": "HK1", "room": "A3.402", "schedule": "Xưởng sáng", "start": "2025-08-11", "end": "2025-09-01", "type": "TH"},
    {"idx": 9, "code": "SQLSERVER(125)_03_TH/K19A2_B", "name": "Hệ quản trị CSDL SQL Server TH (đợt 2)", "subject": "Hệ quản trị CSDL SQL Server", "teacher_idx": 2, "year": "2025-2026", "semester": "HK1", "room": "A3.402", "schedule": "Xưởng chiều", "start": "2025-09-01", "end": "2025-09-21", "type": "TH"},
    {"idx": 10, "code": "TTTNN(225)_01/K17-K18", "name": "Trí tuệ nhân tạo nâng cao", "subject": "Trí tuệ nhân tạo nâng cao", "teacher_idx": 2, "year": "2025-2026", "semester": "HK2", "room": "A2.411", "schedule": "Thứ 4, tiết 1,2", "start": "2026-01-05", "end": "2026-05-10", "type": "LT"},
    {"idx": 11, "code": "CSLTWEB(225)_01/K20A1", "name": "Cơ sở lập trình web", "subject": "Cơ sở lập trình web", "teacher_idx": 2, "year": "2025-2026", "semester": "HK2", "room": "A2.502", "schedule": "Thứ 5, tiết 1,2", "start": "2026-02-02", "end": "2026-06-07", "type": "LT"},
    {"idx": 12, "code": "TCB(225)_08", "name": "Tin học cơ bản", "subject": "Tin học cơ bản", "teacher_idx": 12, "year": "2025-2026", "semester": "HK2", "room": "A2.401", "schedule": "Thứ 5, tiết 6,7,8", "start": "2026-02-02", "end": "2026-06-07", "type": "LT"},
]

# K17 classes that get lots of assignments (priority)
K17_CLASS_INDICES = [5, 6, 10]  # SQL Server TH K17A1, PTUDW1 TH K17A2, TTTNN K17-K18

# ============================================================
# QUESTIONS (MMT & SQL Server - multiple choice only)
# ============================================================
MMT_QUESTIONS = [
    {"text": "Mô hình OSI gồm bao nhiêu tầng?", "choices": [("7 tầng", True), ("5 tầng", False), ("4 tầng", False), ("6 tầng", False)], "explanation": "Mô hình OSI (Open Systems Interconnection) gồm 7 tầng: Physical, Data Link, Network, Transport, Session, Presentation, Application.", "difficulty": 2, "tags": ["mạng", "OSI"]},
    {"text": "Tầng nào trong mô hình OSI chịu trách nhiệm định tuyến (routing)?", "choices": [("Network", True), ("Transport", False), ("Data Link", False), ("Session", False)], "explanation": "Tầng Network (tầng 3) chịu trách nhiệm định tuyến gói tin giữa các mạng.", "difficulty": 2, "tags": ["mạng", "OSI", "routing"]},
    {"text": "Giao thức nào thuộc tầng Transport trong mô hình TCP/IP?", "choices": [("TCP và UDP", True), ("HTTP và FTP", False), ("IP và ICMP", False), ("ARP và RARP", False)], "explanation": "TCP (Transmission Control Protocol) và UDP (User Datagram Protocol) là hai giao thức chính ở tầng Transport.", "difficulty": 2, "tags": ["mạng", "TCP/IP"]},
    {"text": "Địa chỉ IP phiên bản 4 (IPv4) có bao nhiêu bit?", "choices": [("32 bit", True), ("64 bit", False), ("128 bit", False), ("48 bit", False)], "explanation": "IPv4 sử dụng 32 bit, cho phép biểu diễn khoảng 4,3 tỷ địa chỉ.", "difficulty": 1, "tags": ["mạng", "IP"]},
    {"text": "Subnet mask /24 tương đương với giá trị nào?", "choices": [("255.255.255.0", True), ("255.255.0.0", False), ("255.0.0.0", False), ("255.255.255.128", False)], "explanation": "/24 nghĩa là 24 bit đầu là 1, tương đương 255.255.255.0.", "difficulty": 2, "tags": ["mạng", "subnet"]},
    {"text": "Thiết bị nào hoạt động ở tầng Data Link?", "choices": [("Switch", True), ("Router", False), ("Hub", False), ("Repeater", False)], "explanation": "Switch hoạt động ở tầng Data Link (tầng 2), sử dụng MAC address để chuyển frame.", "difficulty": 2, "tags": ["mạng", "thiết bị"]},
    {"text": "Giao thức DHCP dùng để làm gì?", "choices": [("Cấp phát địa chỉ IP tự động", True), ("Phân giải tên miền", False), ("Truyền file", False), ("Gửi email", False)], "explanation": "DHCP (Dynamic Host Configuration Protocol) tự động cấp phát IP, subnet mask, gateway cho các thiết bị trong mạng.", "difficulty": 1, "tags": ["mạng", "DHCP"]},
    {"text": "DNS là viết tắt của gì?", "choices": [("Domain Name System", True), ("Dynamic Network Service", False), ("Data Network Security", False), ("Digital Name Server", False)], "explanation": "DNS (Domain Name System) là hệ thống phân giải tên miền thành địa chỉ IP.", "difficulty": 1, "tags": ["mạng", "DNS"]},
    {"text": "VLAN là gì?", "choices": [("Mạng LAN ảo", True), ("Mạng LAN kết nối VPN", False), ("Mạng diện rộng ảo", False), ("Mạng không dây ảo", False)], "explanation": "VLAN (Virtual LAN) cho phép phân chia mạng vật lý thành nhiều mạng logic.", "difficulty": 3, "tags": ["mạng", "VLAN"]},
    {"text": "Giao thức nào được sử dụng để gửi email?", "choices": [("SMTP", True), ("POP3", False), ("FTP", False), ("SNMP", False)], "explanation": "SMTP (Simple Mail Transfer Protocol) dùng để gửi email, POP3/IMAP dùng để nhận.", "difficulty": 1, "tags": ["mạng", "email"]},
]

SQL_QUESTIONS = [
    {"text": "Lệnh SQL nào dùng để tạo bảng mới?", "choices": [("CREATE TABLE", True), ("INSERT TABLE", False), ("MAKE TABLE", False), ("NEW TABLE", False)], "explanation": "CREATE TABLE là câu lệnh DDL dùng để tạo bảng mới trong cơ sở dữ liệu.", "difficulty": 1, "tags": ["SQL", "DDL"]},
    {"text": "Ràng buộc nào đảm bảo giá trị trong cột là duy nhất?", "choices": [("UNIQUE", True), ("CHECK", False), ("DEFAULT", False), ("NOT NULL", False)], "explanation": "UNIQUE constraint đảm bảo tất cả giá trị trong cột là khác nhau.", "difficulty": 2, "tags": ["SQL", "constraint"]},
    {"text": "JOIN nào trả về tất cả bản ghi từ bảng bên trái?", "choices": [("LEFT JOIN", True), ("INNER JOIN", False), ("RIGHT JOIN", False), ("CROSS JOIN", False)], "explanation": "LEFT JOIN trả về tất cả bản ghi từ bảng bên trái và các bản ghi khớp từ bảng bên phải.", "difficulty": 2, "tags": ["SQL", "JOIN"]},
    {"text": "Hàm COUNT(*) dùng để làm gì?", "choices": [("Đếm số bản ghi", True), ("Tính tổng giá trị", False), ("Tìm giá trị lớn nhất", False), ("Tính trung bình", False)], "explanation": "COUNT(*) đếm tổng số hàng (bản ghi) trong kết quả truy vấn.", "difficulty": 1, "tags": ["SQL", "aggregate"]},
    {"text": "Câu lệnh nào dùng để xóa bảng hoàn toàn?", "choices": [("DROP TABLE", True), ("DELETE TABLE", False), ("REMOVE TABLE", False), ("TRUNCATE TABLE", False)], "explanation": "DROP TABLE xóa hoàn toàn bảng (cấu trúc + dữ liệu). TRUNCATE chỉ xóa dữ liệu.", "difficulty": 2, "tags": ["SQL", "DDL"]},
    {"text": "Từ khóa ORDER BY dùng để làm gì?", "choices": [("Sắp xếp kết quả", True), ("Nhóm kết quả", False), ("Lọc kết quả", False), ("Giới hạn kết quả", False)], "explanation": "ORDER BY sắp xếp kết quả theo cột chỉ định, mặc định tăng dần (ASC).", "difficulty": 1, "tags": ["SQL", "query"]},
    {"text": "Stored Procedure trong SQL Server là gì?", "choices": [("Chương trình con được lưu trữ trên server", True), ("Bảng tạm thời", False), ("Ràng buộc toàn vẹn", False), ("View phức tạp", False)], "explanation": "Stored Procedure là tập hợp các câu lệnh SQL được biên dịch sẵn và lưu trên server.", "difficulty": 3, "tags": ["SQL", "stored_procedure"]},
    {"text": "INDEX trong SQL dùng để làm gì?", "choices": [("Tăng tốc độ truy vấn", True), ("Tạo bảng mới", False), ("Sao lưu dữ liệu", False), ("Mã hóa dữ liệu", False)], "explanation": "INDEX tạo cấu trúc tìm kiếm nhanh, giúp database engine truy xuất dữ liệu hiệu quả hơn.", "difficulty": 2, "tags": ["SQL", "performance"]},
    {"text": "Trigger trong SQL Server được kích hoạt khi nào?", "choices": [("Khi có INSERT/UPDATE/DELETE trên bảng", True), ("Khi server khởi động", False), ("Khi user đăng nhập", False), ("Theo lịch định kỳ", False)], "explanation": "Trigger là đoạn mã tự động thực thi khi có thao tác DML (INSERT, UPDATE, DELETE) trên bảng.", "difficulty": 3, "tags": ["SQL", "trigger"]},
    {"text": "Transaction trong SQL đảm bảo tính chất nào?", "choices": [("ACID", True), ("BASE", False), ("REST", False), ("CRUD", False)], "explanation": "Transaction đảm bảo tính ACID: Atomicity, Consistency, Isolation, Durability.", "difficulty": 3, "tags": ["SQL", "transaction"]},
]

# ============================================================
# MAIN GENERATOR
# ============================================================
def main():
    import os
    script_dir = os.path.dirname(os.path.abspath(__file__))
    students_all = parse_students_md(os.path.join(script_dir, '02_students.md'))
    class_members_map = parse_class_members_md(os.path.join(script_dir, '04_class_members.md'))

    # Separate K17 students
    k17a1 = [s for s in students_all if s['section'] and 'K17A1' in s['section']]
    k17a2 = [s for s in students_all if s['section'] and 'K17A2' in s['section']]
    
    # Deduplicate by student_code
    seen_codes = set()
    all_students = []
    for s in k17a1 + k17a2:
        if s['student_code'] not in seen_codes:
            seen_codes.add(s['student_code'])
            all_students.append(s)
    
    # For other classes (non-K17), take 20 representative from class_members
    # We need to add students that appear in class_members but not in K17 lists
    for cls_idx, members in class_members_map.items():
        count = 0
        for m in members:
            if m['student_code'] not in seen_codes and count < 20:
                seen_codes.add(m['student_code'])
                all_students.append({
                    'student_code': m['student_code'],
                    'enrollment_class': m['enrollment_class'],
                    'full_name': m['full_name'],
                    'dob': None,
                    'email': f"sv_{m['student_code']}@school.edu.vn",
                    'section': m['enrollment_class'],
                })
                count += 1

    print(f"Total unique students: {len(all_students)}")
    print(f"  K17A1: {len(k17a1)}, K17A2: {len(k17a2)}")

    # Build UUID maps
    teacher_ids = {}
    for i, t in enumerate(TEACHERS):
        teacher_ids[i] = make_uuid(f"teacher.{t['email']}")
    
    student_ids = {}
    for s in all_students:
        student_ids[s['student_code']] = make_uuid(f"student.{s['student_code']}")
    
    class_ids = {}
    for c in CLASSES_DEF:
        class_ids[c['idx']] = make_uuid(f"class.{c['code']}")

    # GV Phạm Thị Đào is teacher_idx=2 (most K17 classes)
    dao_id = teacher_ids[2]

    lines = []
    lines.append("-- ============================================================")
    lines.append("-- AUTO-GENERATED SEED DATA — DO NOT EDIT MANUALLY")
    lines.append(f"-- Generated: {datetime.now().isoformat()}")
    lines.append("-- ============================================================")
    lines.append("BEGIN;")
    lines.append("")
    lines.append("-- Disable FK checks for bulk insert")
    lines.append("SET session_replication_role = replica;")
    lines.append("")

    # ======= 1. SCHOOL =======
    lines.append("-- ═══ 1. SCHOOLS ═══")
    metadata = json.dumps({"faculty": "Khoa Công nghệ Thông tin", "city": "Vinh, Nghệ An"}, ensure_ascii=False)
    lines.append(f"INSERT INTO public.schools (id, name, metadata) VALUES ({sql_escape(SCHOOL_ID)}, {sql_escape(SCHOOL_NAME)}, {sql_escape(metadata)}) ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 2. AUTH.USERS (Teachers) =======
    lines.append("-- ═══ 2. AUTH.USERS — Teachers ═══")
    for i, t in enumerate(TEACHERS):
        tid = teacher_ids[i]
        meta = json.dumps({"full_name": t['name'], "role": "teacher", "phone": t['phone']}, ensure_ascii=False)
        lines.append(f"""INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data, email_confirmed_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000000000', {sql_escape(tid)}, 'authenticated', 'authenticated', {sql_escape(t['email'])}, crypt('12345678', gen_salt('bf')),
'{{"provider": "email", "providers": ["email"]}}', {sql_escape(meta)}, now(), now(), now()) ON CONFLICT (id) DO NOTHING;""")
    lines.append("")

    # ======= 3. AUTH.USERS (Students) =======
    lines.append("-- ═══ 3. AUTH.USERS — Students ═══")
    for s in all_students:
        sid = student_ids[s['student_code']]
        meta = json.dumps({"full_name": s['full_name'], "role": "student"}, ensure_ascii=False)
        lines.append(f"""INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data, email_confirmed_at, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000000000', {sql_escape(sid)}, 'authenticated', 'authenticated', {sql_escape(s['email'])}, crypt('12345678', gen_salt('bf')),
'{{"provider": "email", "providers": ["email"]}}', {sql_escape(meta)}, now(), now(), now()) ON CONFLICT (id) DO NOTHING;""")
    lines.append("")

    # ======= 4. AUTH.IDENTITIES =======
    lines.append("-- ═══ 4. AUTH.IDENTITIES ═══")
    for i, t in enumerate(TEACHERS):
        tid = teacher_ids[i]
        lines.append(f"""INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
VALUES (gen_random_uuid(), {sql_escape(t['email'])}, {sql_escape(tid)}, json_build_object('sub', {sql_escape(tid)}, 'email', {sql_escape(t['email'])})::jsonb, 'email', now(), now(), now()) ON CONFLICT DO NOTHING;""")
    for s in all_students:
        sid = student_ids[s['student_code']]
        lines.append(f"""INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
VALUES (gen_random_uuid(), {sql_escape(s['email'])}, {sql_escape(sid)}, json_build_object('sub', {sql_escape(sid)}, 'email', {sql_escape(s['email'])})::jsonb, 'email', now(), now(), now()) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 5. PROFILES =======
    lines.append("-- ═══ 5. PROFILES ═══")
    for i, t in enumerate(TEACHERS):
        tid = teacher_ids[i]
        meta = json.dumps({"school_name": SCHOOL_NAME, "degree_title": t['degree'], "address": t['address']}, ensure_ascii=False)
        lines.append(f"""INSERT INTO public.profiles (id, full_name, role, phone, metadata)
VALUES ({sql_escape(tid)}, {sql_escape(t['name'])}, 'teacher', {sql_escape(t['phone'])}, {sql_escape(meta)}) ON CONFLICT (id) DO UPDATE SET full_name=EXCLUDED.full_name, role=EXCLUDED.role, phone=EXCLUDED.phone, metadata=EXCLUDED.metadata;""")
    for s in all_students:
        sid = student_ids[s['student_code']]
        meta = json.dumps({"student_code": s['student_code'], "enrollment_class": s['enrollment_class'], "school_name": SCHOOL_NAME}, ensure_ascii=False)
        lines.append(f"""INSERT INTO public.profiles (id, full_name, role, metadata)
VALUES ({sql_escape(sid)}, {sql_escape(s['full_name'])}, 'student', {sql_escape(meta)}) ON CONFLICT (id) DO UPDATE SET full_name=EXCLUDED.full_name, role=EXCLUDED.role, metadata=EXCLUDED.metadata;""")
    lines.append("")

    # ======= 6. CLASSES =======
    lines.append("-- ═══ 6. CLASSES ═══")
    for c in CLASSES_DEF:
        cid = class_ids[c['idx']]
        tid = teacher_ids[c['teacher_idx']]
        settings = json.dumps({
            "defaults": {"lock_class": False},
            "enrollment": {"qr_code": {"is_active": False, "join_code": None, "expires_at": None, "require_approval": True}, "manual_join_limit": None},
            "group_management": {"lock_groups": False, "allow_student_switch": False, "is_visible_to_students": True},
            "student_permissions": {"auto_lock_on_submission": False, "can_edit_profile_in_class": True},
            "schedule": c['schedule'], "room": c['room'], "class_type": c['type'], "class_code": c['code']
        }, ensure_ascii=False)
        lines.append(f"""INSERT INTO public.classes (id, school_id, teacher_id, name, subject, academic_year, class_settings, created_at)
VALUES ({sql_escape(cid)}, {sql_escape(SCHOOL_ID)}, {sql_escape(tid)}, {sql_escape(c['code'] + ' - ' + c['name'])}, {sql_escape(c['subject'])}, {sql_escape(c['year'])}, {sql_escape(settings)}, {sql_escape(c['start'] + 'T00:00:00+07:00')}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 7. CLASS_TEACHERS =======
    lines.append("-- ═══ 7. CLASS_TEACHERS ═══")
    for c in CLASSES_DEF:
        cid = class_ids[c['idx']]
        tid = teacher_ids[c['teacher_idx']]
        ct_id = make_uuid(f"class_teacher.{c['idx']}.{c['teacher_idx']}")
        lines.append(f"INSERT INTO public.class_teachers (id, class_id, teacher_id, role) VALUES ({sql_escape(ct_id)}, {sql_escape(cid)}, {sql_escape(tid)}, 'teacher') ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 8. CLASS_MEMBERS =======
    lines.append("-- ═══ 8. CLASS_MEMBERS ═══")
    for cls_idx, members in class_members_map.items():
        cid = class_ids.get(cls_idx)
        if not cid:
            continue
        for m in members:
            sid = student_ids.get(m['student_code'])
            if sid:
                joined = BASE_DATE + timedelta(days=random.randint(-5, 5))
                lines.append(f"INSERT INTO public.class_members (class_id, student_id, role, status, joined_at) VALUES ({sql_escape(cid)}, {sql_escape(sid)}, 'student', 'approved', {sql_escape(joined.isoformat())}) ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 9. GROUPS =======
    lines.append("-- ═══ 9. GROUPS ═══")
    group_ids = {}
    for cls_idx in [6, 10]:  # SQL Server K17A1 and TTTNN K17-K18
        for g in range(1, 4):
            gid = make_uuid(f"group.{cls_idx}.{g}")
            group_ids[(cls_idx, g)] = gid
            cid = class_ids[cls_idx]
            tid = teacher_ids[CLASSES_DEF[cls_idx-1]['teacher_idx']]
            lines.append(f"INSERT INTO public.groups (id, class_id, name, description, teacher_id, created_at) VALUES ({sql_escape(gid)}, {sql_escape(cid)}, {sql_escape(f'Nhóm {g}')}, {sql_escape(f'Nhóm thảo luận {g}')}, {sql_escape(tid)}, {sql_escape(BASE_DATE.isoformat())}) ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 10. GROUP_MEMBERS =======
    lines.append("-- ═══ 10. GROUP_MEMBERS ═══")
    for cls_idx in [6, 10]:
        members = class_members_map.get(cls_idx, [])
        for i, m in enumerate(members):
            sid = student_ids.get(m['student_code'])
            if sid:
                g_num = (i % 3) + 1
                gid = group_ids.get((cls_idx, g_num))
                if gid:
                    lines.append(f"INSERT INTO public.group_members (group_id, student_id, role, joined_at) VALUES ({sql_escape(gid)}, {sql_escape(sid)}, 'member', {sql_escape(BASE_DATE.isoformat())}) ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 11. QUESTIONS =======
    lines.append("-- ═══ 11. QUESTIONS ═══")
    question_ids = {}
    all_questions = []
    for i, q in enumerate(MMT_QUESTIONS):
        qid = make_uuid(f"question.mmt.{i}")
        question_ids[('mmt', i)] = qid
        content = json.dumps({"text": q['text']}, ensure_ascii=False)
        answer = json.dumps({"correct_choice_ids": [j for j, c in enumerate(q['choices']) if c[1]], "general_explanation": q['explanation']}, ensure_ascii=False)
        tags_sql = "ARRAY[" + ",".join([sql_escape(t) for t in q['tags']]) + "]::text[]"
        lines.append(f"""INSERT INTO public.questions (id, author_id, type, content, answer, default_points, difficulty, tags, is_public, created_at, updated_at)
VALUES ({sql_escape(qid)}, {sql_escape(dao_id)}, 'multiple_choice', {sql_escape(content)}, {sql_escape(answer)}, 1, {q['difficulty']}, {tags_sql}, true, {sql_escape((BASE_DATE - timedelta(days=10)).isoformat())}, {sql_escape((BASE_DATE - timedelta(days=10)).isoformat())}) ON CONFLICT DO NOTHING;""")
        all_questions.append(('mmt', i, q))
    
    for i, q in enumerate(SQL_QUESTIONS):
        qid = make_uuid(f"question.sql.{i}")
        question_ids[('sql', i)] = qid
        content = json.dumps({"text": q['text']}, ensure_ascii=False)
        answer = json.dumps({"correct_choice_ids": [j for j, c in enumerate(q['choices']) if c[1]], "general_explanation": q['explanation']}, ensure_ascii=False)
        tags_sql = "ARRAY[" + ",".join([sql_escape(t) for t in q['tags']]) + "]::text[]"
        lines.append(f"""INSERT INTO public.questions (id, author_id, type, content, answer, default_points, difficulty, tags, is_public, created_at, updated_at)
VALUES ({sql_escape(qid)}, {sql_escape(dao_id)}, 'multiple_choice', {sql_escape(content)}, {sql_escape(answer)}, 1, {q['difficulty']}, {tags_sql}, true, {sql_escape((BASE_DATE - timedelta(days=10)).isoformat())}, {sql_escape((BASE_DATE - timedelta(days=10)).isoformat())}) ON CONFLICT DO NOTHING;""")
        all_questions.append(('sql', i, q))
    lines.append("")

    # ======= 12. QUESTION_CHOICES =======
    lines.append("-- ═══ 12. QUESTION_CHOICES ═══")
    for (cat, idx), qid in question_ids.items():
        q = MMT_QUESTIONS[idx] if cat == 'mmt' else SQL_QUESTIONS[idx]
        for ci, (text, is_correct) in enumerate(q['choices']):
            content = json.dumps({"text": text}, ensure_ascii=False)
            lines.append(f"INSERT INTO public.question_choices (id, question_id, content, is_correct) VALUES ({ci}, {sql_escape(qid)}, {sql_escape(content)}, {'true' if is_correct else 'false'}) ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 13. ASSIGNMENTS =======
    lines.append("-- ═══ 13. ASSIGNMENTS ═══")
    # 6 assignments for K17: 3 MMT + 3 SQL Server
    ASSIGNMENTS = [
        {"key": "mmt_mid", "title": "Kiểm tra giữa kỳ Mạng máy tính", "desc": "Bài kiểm tra giữa kỳ - 10 câu trắc nghiệm", "class_idx": 10, "questions": [('mmt', i) for i in range(10)], "total_points": 10, "date_offset": 30},
        {"key": "mmt_hw1", "title": "Bài tập chương 1: Mô hình OSI", "desc": "Bài tập về mô hình OSI và các tầng mạng", "class_idx": 10, "questions": [('mmt', i) for i in range(5)], "total_points": 10, "date_offset": 14},
        {"key": "mmt_hw2", "title": "Bài tập chương 2: Địa chỉ IP và Subnet", "desc": "Bài tập về subnet, DHCP, DNS", "class_idx": 10, "questions": [('mmt', i) for i in range(4, 10)], "total_points": 10, "date_offset": 45},
        {"key": "sql_mid", "title": "Kiểm tra giữa kỳ SQL Server", "desc": "Bài kiểm tra giữa kỳ CSDL SQL Server", "class_idx": 6, "questions": [('sql', i) for i in range(10)], "total_points": 10, "date_offset": 35},
        {"key": "sql_hw1", "title": "Bài tập DDL và Constraint", "desc": "Bài tập về CREATE TABLE, ràng buộc", "class_idx": 6, "questions": [('sql', i) for i in range(5)], "total_points": 10, "date_offset": 10},
        {"key": "sql_hw2", "title": "Bài tập JOIN và Aggregate", "desc": "Bài tập về JOIN, GROUP BY, COUNT", "class_idx": 6, "questions": [('sql', i) for i in range(3, 8)], "total_points": 10, "date_offset": 50},
    ]

    assignment_ids = {}
    aq_ids = {}  # assignment_question_ids
    for a in ASSIGNMENTS:
        aid = make_uuid(f"assignment.{a['key']}")
        assignment_ids[a['key']] = aid
        cid = class_ids[a['class_idx']]
        publish_date = BASE_DATE + timedelta(days=a['date_offset'] - 7)
        lines.append(f"""INSERT INTO public.assignments (id, class_id, teacher_id, title, description, is_published, published_at, total_points, created_at, updated_at)
VALUES ({sql_escape(aid)}, {sql_escape(cid)}, {sql_escape(dao_id)}, {sql_escape(a['title'])}, {sql_escape(a['desc'])}, true, {sql_escape(publish_date.isoformat())}, {a['total_points']}, {sql_escape(publish_date.isoformat())}, {sql_escape(publish_date.isoformat())}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 14. ASSIGNMENT_QUESTIONS =======
    lines.append("-- ═══ 14. ASSIGNMENT_QUESTIONS ═══")
    for a in ASSIGNMENTS:
        aid = assignment_ids[a['key']]
        pts_per_q = a['total_points'] / len(a['questions'])
        for order, (cat, qi) in enumerate(a['questions']):
            aq_id = make_uuid(f"aq.{a['key']}.{cat}.{qi}")
            aq_ids[(a['key'], cat, qi)] = aq_id
            qid = question_ids[(cat, qi)]
            lines.append(f"""INSERT INTO public.assignment_questions (id, assignment_id, question_id, points, order_idx)
VALUES ({sql_escape(aq_id)}, {sql_escape(aid)}, {sql_escape(qid)}, {pts_per_q:.2f}, {order + 1}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 15. ASSIGNMENT_DISTRIBUTIONS =======
    lines.append("-- ═══ 15. ASSIGNMENT_DISTRIBUTIONS ═══")
    dist_ids = {}
    for a in ASSIGNMENTS:
        did = make_uuid(f"dist.{a['key']}")
        dist_ids[a['key']] = did
        aid = assignment_ids[a['key']]
        cid = class_ids[a['class_idx']]
        avail = BASE_DATE + timedelta(days=a['date_offset'] - 7)
        due = BASE_DATE + timedelta(days=a['date_offset'])
        settings = json.dumps({"shuffle_questions": False, "shuffle_choices": False, "show_score_immediately": True}, ensure_ascii=False)
        lines.append(f"""INSERT INTO public.assignment_distributions (id, assignment_id, distribution_type, class_id, available_from, due_at, time_limit_minutes, allow_late, status, settings, created_at)
VALUES ({sql_escape(did)}, {sql_escape(aid)}, 'class', {sql_escape(cid)}, {sql_escape(avail.isoformat())}, {sql_escape(due.isoformat())}, 45, true, 'closed', {sql_escape(settings)}, {sql_escape(avail.isoformat())}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 16-18. WORK_SESSIONS, SUBMISSIONS, SUBMISSION_ANSWERS =======
    lines.append("-- ═══ 16-18. WORK_SESSIONS, SUBMISSIONS, SUBMISSION_ANSWERS ═══")
    
    for a in ASSIGNMENTS:
        cls_idx = a['class_idx']
        class_member_list = class_members_map.get(cls_idx, [])
        aid = assignment_ids[a['key']]
        did = dist_ids[a['key']]
        
        for mi, m in enumerate(class_member_list):
            sid = student_ids.get(m['student_code'])
            if not sid:
                continue
            
            # Simulate varied submission times
            submit_day = a['date_offset'] - random.randint(0, 3)
            start_time = BASE_DATE + timedelta(days=submit_day, hours=random.randint(8, 20), minutes=random.randint(0, 59))
            time_spent = random.randint(600, 2700)  # 10-45 minutes
            submit_time = start_time + timedelta(seconds=time_spent)
            is_late = submit_day > a['date_offset']
            
            ws_id = make_uuid(f"ws.{a['key']}.{m['student_code']}")
            sub_id = make_uuid(f"sub.{a['key']}.{m['student_code']}")
            
            # Generate score (bell curve around 6.5-7.5 / 10)
            base_score_pct = random.gauss(0.7, 0.15)
            base_score_pct = max(0.2, min(1.0, base_score_pct))
            
            lines.append(f"""INSERT INTO public.work_sessions (id, assignment_distribution_id, assignment_id, student_id, started_at, submitted_at, attempt, status, time_spent_seconds, created_at, updated_at)
VALUES ({sql_escape(ws_id)}, {sql_escape(did)}, {sql_escape(aid)}, {sql_escape(sid)}, {sql_escape(start_time.isoformat())}, {sql_escape(submit_time.isoformat())}, 1, 'submitted', {time_spent}, {sql_escape(start_time.isoformat())}, {sql_escape(submit_time.isoformat())}) ON CONFLICT DO NOTHING;""")
            
            # Calculate total score from individual answers
            total_score = 0
            pts_per_q = a['total_points'] / len(a['questions'])
            
            for cat, qi in a['questions']:
                aq_id = aq_ids[(a['key'], cat, qi)]
                q = MMT_QUESTIONS[qi] if cat == 'mmt' else SQL_QUESTIONS[qi]
                correct_ids = [j for j, c in enumerate(q['choices']) if c[1]]
                
                # Student answers — some correct, some wrong
                if random.random() < base_score_pct:
                    selected = correct_ids  # Correct answer
                    score = pts_per_q
                else:
                    wrong_choices = [j for j in range(len(q['choices'])) if j not in correct_ids]
                    selected = [random.choice(wrong_choices)] if wrong_choices else correct_ids
                    score = 0
                total_score += score
                
                sa_id = make_uuid(f"sa.{a['key']}.{m['student_code']}.{cat}.{qi}")
                answer_json = json.dumps({"selected_choice_ids": selected}, ensure_ascii=False)
                lines.append(f"""INSERT INTO public.submission_answers (id, session_id, assignment_question_id, answer, final_score, ai_score, ai_confidence, created_at, updated_at)
VALUES ({sql_escape(sa_id)}, {sql_escape(ws_id)}, {sql_escape(aq_id)}, {sql_escape(answer_json)}, {score:.2f}, {score:.2f}, {random.uniform(0.85, 0.99):.2f}, {sql_escape(submit_time.isoformat())}, {sql_escape(submit_time.isoformat())}) ON CONFLICT DO NOTHING;""")
            
            total_score = round(total_score, 2)
            lines.append(f"""INSERT INTO public.submissions (id, assignment_id, assignment_distribution_id, student_id, session_id, started_at, submitted_at, is_late, total_score, ai_graded, created_at, updated_at)
VALUES ({sql_escape(sub_id)}, {sql_escape(aid)}, {sql_escape(did)}, {sql_escape(sid)}, {sql_escape(ws_id)}, {sql_escape(start_time.isoformat())}, {sql_escape(submit_time.isoformat())}, {'true' if is_late else 'false'}, {total_score}, true, {sql_escape(submit_time.isoformat())}, {sql_escape(submit_time.isoformat())}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 19. QUESTION_STATS =======
    lines.append("-- ═══ 19. QUESTION_STATS ═══")
    for (cat, qi), qid in question_ids.items():
        total = random.randint(40, 100)
        correct = int(total * random.uniform(0.5, 0.85))
        avg = round(correct / total, 2)
        lines.append(f"INSERT INTO public.question_stats (question_id, total_attempts, correct_count, avg_score, last_attempted) VALUES ({sql_escape(qid)}, {total}, {correct}, {avg}, {sql_escape((BASE_DATE + timedelta(days=60)).isoformat())}) ON CONFLICT DO NOTHING;")
    lines.append("")

    # ======= 20. AI_RECOMMENDATIONS =======
    lines.append("-- ═══ 20. AI_RECOMMENDATIONS ═══")
    recommendations = [
        {"title": "Ôn tập mô hình OSI cho lớp TTTNN", "desc": "Nhiều sinh viên còn nhầm lẫn giữa các tầng Network và Transport. Nên bổ sung bài tập thực hành.", "type": "class", "priority": 4, "cls": 10},
        {"title": "Bổ sung bài tập Subnet cho nhóm yếu", "desc": "Nhóm 5 sinh viên điểm dưới 5 cần được hỗ trợ thêm về Subnetting.", "type": "small_group", "priority": 5, "cls": 10},
        {"title": "Sinh viên Thái Anh Huy có tiến bộ vượt bậc", "desc": "Điểm tăng từ 6 lên 9 trong 3 bài kiểm tra liên tiếp. Có thể giao bài nâng cao.", "type": "individual", "priority": 3, "cls": 10},
        {"title": "Ôn tập Stored Procedure cho K17A1", "desc": "Tỷ lệ đúng câu Stored Procedure rất thấp (35%). Cần ôn lại kiến thức.", "type": "class", "priority": 4, "cls": 6},
        {"title": "Bổ sung bài tập Transaction/ACID", "desc": "Chủ đề Transaction có độ khó cao, nhiều SV chưa nắm vững ACID.", "type": "class", "priority": 3, "cls": 6},
    ]
    for ri, r in enumerate(recommendations):
        rid = make_uuid(f"rec.{ri}")
        cid = class_ids[r['cls']]
        tid = dao_id
        resources = json.dumps({"exercises": [], "videos": [], "documents": []}, ensure_ascii=False)
        created = BASE_DATE + timedelta(days=random.randint(30, 70))
        lines.append(f"""INSERT INTO public.ai_recommendations (id, teacher_id, class_id, type, priority, title, description, resources, dismissed, created_at)
VALUES ({sql_escape(rid)}, {sql_escape(tid)}, {sql_escape(cid)}, {sql_escape(r['type'])}, {r['priority']}, {sql_escape(r['title'])}, {sql_escape(r['desc'])}, {sql_escape(resources)}, false, {sql_escape(created.isoformat())}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= 21. TEACHER_NOTES =======
    lines.append("-- ═══ 21. TEACHER_NOTES ═══")
    notes = [
        ("Sinh viên chăm chỉ, nộp bài đúng hạn. Cần cải thiện phần subnetting.", k17a1[0] if k17a1 else None),
        ("Vắng nhiều buổi, cần nhắc nhở. Điểm giữa kỳ thấp.", k17a1[5] if len(k17a1) > 5 else None),
        ("Có khả năng lãnh đạo nhóm tốt. Giúp đỡ bạn cùng nhóm.", k17a2[0] if k17a2 else None),
    ]
    for ni, (content, student) in enumerate(notes):
        if student:
            nid = make_uuid(f"note.{ni}")
            sid = student_ids.get(student['student_code'])
            if sid:
                lines.append(f"""INSERT INTO public.teacher_notes (id, teacher_id, student_id, content, is_private, created_at)
VALUES ({sql_escape(nid)}, {sql_escape(dao_id)}, {sql_escape(sid)}, {sql_escape(content)}, true, {sql_escape((BASE_DATE + timedelta(days=40)).isoformat())}) ON CONFLICT DO NOTHING;""")
    lines.append("")

    # ======= FINALIZE =======
    lines.append("-- Re-enable FK checks")
    lines.append("SET session_replication_role = DEFAULT;")
    lines.append("")
    lines.append("COMMIT;")
    lines.append("")
    lines.append("-- ═══ VERIFY ═══")
    lines.append("SELECT relname AS table_name, n_live_tup AS row_count FROM pg_stat_user_tables WHERE schemaname='public' ORDER BY relname;")

    # Write output
    output_path = os.path.join(script_dir, '06_full_seed.sql')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"✅ Generated: {output_path}")
    print(f"   Total lines: {len(lines)}")

if __name__ == '__main__':
    main()
