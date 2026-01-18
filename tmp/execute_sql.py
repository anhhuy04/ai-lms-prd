#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để thực thi SQL INSERT vào Supabase database
"""
import os
import sys
import io

# Set UTF-8 encoding for output
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

from supabase import create_client, Client

# Supabase credentials từ supabase_service.dart
SUPABASE_URL = "https://vazhgunhcjdwlkbslroc.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhemhndW5oY2pkd2xrYnNscm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxMTI3NTksImV4cCI6MjA4MDY4ODc1OX0.D-O3FbXF46mVEga152RmumAkmqS54_A-L7tFa6UBi0c"

def execute_sql():
    """Thực thi SQL từ file create_20_classes.sql"""
    try:
        # Khởi tạo Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Đọc SQL từ file
        sql_file = os.path.join(os.path.dirname(__file__), "create_20_classes.sql")
        with open(sql_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Loại bỏ comments và lấy phần INSERT
        sql_lines = []
        for line in sql_content.split('\n'):
            line = line.strip()
            if line and not line.startswith('--'):
                sql_lines.append(line)
        
        sql = ' '.join(sql_lines)
        
        # Thực thi SQL thông qua RPC hoặc direct query
        # Supabase Python client không hỗ trợ execute SQL trực tiếp
        # Nên chúng ta sẽ parse và insert từng record
        
        print("Dang thuc thi SQL de tao 20 lop hoc...")
        
        # Parse SQL để lấy các giá trị
        # Tìm phần VALUES
        if 'VALUES' in sql:
            values_part = sql.split('VALUES')[1].strip().rstrip(';')
            
            # Split các records (tách bởi dấu phẩy và dấu ngoặc đơn)
            # Đây là cách đơn giản, nhưng có thể cần parse phức tạp hơn
            
            # Thay vào đó, chúng ta sẽ insert từng record một cách thủ công
            # hoặc sử dụng Supabase REST API
            
        # Cách tốt hơn: Sử dụng Supabase client để insert từng record
        classes_data = [
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Tin học đại cương",
                "subject": "2102033",
                "academic_year": "1",
                "description": "Môn học cơ bản về tin học và máy tính",
                "class_settings": {
                    "enrollment": {
                        "qr_code": {
                            "join_code": None,
                            "is_active": False,
                            "require_approval": True,
                            "expires_at": None
                        },
                        "manual_join_limit": None
                    },
                    "group_management": {
                        "is_visible_to_students": True,
                        "allow_student_switch": False,
                        "lock_groups": False
                    },
                    "student_permissions": {
                        "can_edit_profile_in_class": True,
                        "auto_lock_on_submission": False
                    },
                    "defaults": {
                        "lock_class": False
                    }
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Đồ họa máy tính",
                "subject": "2102008",
                "academic_year": "1",
                "description": "Môn học về đồ họa và xử lý hình ảnh trên máy tính",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Ngôn ngữ lập trình C/C++",
                "subject": "2102034",
                "academic_year": "2",
                "description": "Môn học về lập trình cơ bản với ngôn ngữ C và C++",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Nhập môn Công nghệ thông tin",
                "subject": "2102035",
                "academic_year": "2",
                "description": "Môn học giới thiệu về công nghệ thông tin",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Kiến trúc máy tính",
                "subject": "2102009",
                "academic_year": "3",
                "description": "Môn học về cấu trúc và kiến trúc của máy tính",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Cấu trúc dữ liệu và giải thuật",
                "subject": "2102036",
                "academic_year": "3",
                "description": "Môn học về cấu trúc dữ liệu và các thuật toán cơ bản",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Lập trình hướng đối tượng",
                "subject": "2102038",
                "academic_year": "3",
                "description": "Môn học về lập trình hướng đối tượng (OOP)",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Cơ sở dữ liệu",
                "subject": "2102039",
                "academic_year": "3",
                "description": "Môn học về cơ sở dữ liệu và hệ quản trị cơ sở dữ liệu",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Hệ điều hành",
                "subject": "2102010",
                "academic_year": "4",
                "description": "Môn học về hệ điều hành và quản lý tài nguyên hệ thống",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Mạng máy tính",
                "subject": "2102011",
                "academic_year": "4",
                "description": "Môn học về mạng máy tính và giao thức mạng",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Hệ quản trị cơ sở dữ liệu",
                "subject": "2102041",
                "academic_year": "4",
                "description": "Môn học về hệ quản trị cơ sở dữ liệu và SQL",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Phân tích và thiết kế hệ thống thông tin",
                "subject": "2102043",
                "academic_year": "4",
                "description": "Môn học về phân tích và thiết kế hệ thống thông tin",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Lập trình Java",
                "subject": "2102045",
                "academic_year": "4",
                "description": "Môn học về lập trình Java và các framework",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Thiết kế Web",
                "subject": "2102044",
                "academic_year": "5",
                "description": "Môn học về thiết kế và phát triển website",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Công nghệ phần mềm",
                "subject": "2102046",
                "academic_year": "5",
                "description": "Môn học về quy trình phát triển phần mềm",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Lập trình .NET",
                "subject": "2102048",
                "academic_year": "5",
                "description": "Môn học về lập trình với .NET framework",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Trí tuệ nhân tạo",
                "subject": "2102050",
                "academic_year": "5",
                "description": "Môn học về trí tuệ nhân tạo và machine learning",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "An toàn và bảo mật thông tin",
                "subject": "2102052",
                "academic_year": "5",
                "description": "Môn học về an toàn và bảo mật thông tin",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Lập trình Web nâng cao",
                "subject": "2102053",
                "academic_year": "6",
                "description": "Môn học về lập trình web nâng cao và các framework",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Lập trình di động",
                "subject": "2102055",
                "academic_year": "6",
                "description": "Môn học về lập trình ứng dụng di động",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Kiểm thử và đảm bảo chất lượng PM",
                "subject": "2102057",
                "academic_year": "6",
                "description": "Môn học về kiểm thử phần mềm và đảm bảo chất lượng",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            },
            {
                "teacher_id": "d810df06-78c5-441c-8eaf-90e6e505adad",
                "name": "Quản trị dự án phần mềm",
                "subject": "2102059",
                "academic_year": "6",
                "description": "Môn học về quản trị và quản lý dự án phần mềm",
                "class_settings": {
                    "enrollment": {"qr_code": {"join_code": None, "is_active": False, "require_approval": True, "expires_at": None}, "manual_join_limit": None},
                    "group_management": {"is_visible_to_students": True, "allow_student_switch": False, "lock_groups": False},
                    "student_permissions": {"can_edit_profile_in_class": True, "auto_lock_on_submission": False},
                    "defaults": {"lock_class": False}
                }
            }
        ]
        
        # Insert từng lớp học
        success_count = 0
        error_count = 0
        
        for i, class_data in enumerate(classes_data, 1):
            try:
                result = supabase.table("classes").insert(class_data).execute()
                print(f"[OK] [{i}/20] Da tao lop: {class_data['name']}")
                success_count += 1
            except Exception as e:
                print(f"[ERROR] [{i}/20] Loi khi tao lop {class_data['name']}: {str(e)}")
                error_count += 1
        
        print(f"\nKet qua:")
        print(f"   Thanh cong: {success_count}/20")
        print(f"   Loi: {error_count}/20")
        
        if success_count == 20:
            print("\nDa tao thanh cong 20 lop hoc!")
        else:
            print(f"\nCo {error_count} lop hoc khong duoc tao thanh cong.")
            
    except Exception as e:
        print(f"Loi: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    execute_sql()
