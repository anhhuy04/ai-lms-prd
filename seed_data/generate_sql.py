import os
import json
import hashlib

def to_uuid(prefix, val):
    h = hashlib.md5(f"{prefix}_{val}".encode('utf-8')).hexdigest()
    return f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:]}"

def escape_sql(s):
    if s is None:
        return 'NULL'
    return "'" + str(s).replace("'", "''") + "'"

seed_dir = r"d:\code\Flutter_Android\Flutter_Android\AI_LMS_PRD\seed_data"

out_lines = []
out_lines.append("-- AUTO-GENERATED IMPORT SCRIPT")
out_lines.append("BEGIN;")

# We need to map roles correctly. auth.users requires instance_id, id, aud, role, email, encrypted_password, raw_app_meta_data, raw_user_meta_data
def insert_auth_user(uid, email, full_name, role):
    meta = json.dumps({"full_name": full_name, "role": role})
    return f"""
INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, 
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000', {escape_sql(uid)}, 'authenticated', 'authenticated', {escape_sql(email)}, crypt('12345678', gen_salt('bf')),
    '{{"provider": "email", "providers": ["email"]}}', {escape_sql(meta)}, now(), now()
) ON CONFLICT (id) DO NOTHING;
"""

def update_profile(uid, metadata, role):
    if not metadata or metadata == 'null':
        metadata = "'{}'::jsonb"
    else:
        # Strip backticks safely
        metadata_clean = metadata.strip().strip('`').replace("'", "''")
        metadata = "'" + metadata_clean + "'::jsonb"
    return f"""
UPDATE public.profiles 
SET metadata = {metadata}, role = '{role.replace("'", "''")}'
WHERE id = '{uid}';
"""

# -----------------
# 1. SCHOOLS
# -----------------
school_map = {}
with open(os.path.join(seed_dir, '01_school_and_teachers.md'), 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('|') and 'Tên trường' not in line and '---' not in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 6:
                # Based on 01_school_and_teachers.md: STT | Họ và tên | Chuyên môn | Cấp bậc | Trường | Metadata (JSON)
                # Wait, STT | Tên trường | Địa chỉ | Loại trường | metadata? 
                # Let's assume there's a known schema or we just parse Teachers and Schools.
                # Actually, I'll extract schools from the teacher metadata or we just create a hardcoded school.
                pass

# Let's read teachers and extract unique schools
teachers = []
schools = set()
with open(os.path.join(seed_dir, '01_school_and_teachers.md'), 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('|') and '---' not in line and 'STT' not in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 6 and parts[1] != '':
                # 1: Họ và tên, 2: Chuyên môn, 3: Cấp bậc, 4: Trường, 5: Metadata
                name = parts[1]
                major = parts[2]
                degree = parts[3]
                school = parts[4]
                meta = parts[5] if len(parts) > 5 else "{}"
                if not meta.strip().startswith('{'):
                    meta = json.dumps({"address": meta})
                
                email = "gv_" + hashlib.md5(name.encode('utf-8')).hexdigest()[:6] + "@school.edu.vn"
                
                if school:
                    schools.add(school)
                
                tid = to_uuid('teacher', name)
                teachers.append((tid, email, name, meta))

for s in schools:
    sid = to_uuid('school', s)
    out_lines.append(f"INSERT INTO public.schools (id, name) VALUES ({escape_sql(sid)}, {escape_sql(s)}) ON CONFLICT DO NOTHING;")

for tid, email, name, meta in teachers:
    out_lines.append(insert_auth_user(tid, email, name, 'teacher'))
    out_lines.append(update_profile(tid, meta, 'teacher'))

# -----------------
# 2. STUDENTS
# -----------------
with open(os.path.join(seed_dir, '02_students.md'), 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('|') and '---' not in line and 'STT' not in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 6:
                # STT | Mã SV | Lớp nhập học | Họ và tên | Ngày sinh | Email | Metadata
                student_code = parts[1]
                name = parts[3]
                email = parts[5]
                meta = parts[6] if len(parts) > 6 else "{}"
                if '@' not in email: continue # Skip invalid rows
                
                sid = to_uuid('student', student_code)
                # Ensure email uniqueness if there are duplicates just in case
                out_lines.append(insert_auth_user(sid, email, name, 'student'))
                out_lines.append(update_profile(sid, meta, 'student'))

# -----------------
# 3. CLASSES
# -----------------
class_map = {}
with open(os.path.join(seed_dir, '03_classes.md'), 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('|') and '---' not in line and 'STT' not in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 6:
                # STT | Mã Lớp HP | Tên môn học | Giảng viên | Năm học | Học kỳ
                class_code = parts[1]
                subject = parts[2]
                teacher_name = parts[3]
                year = parts[4]
                semester = parts[5].replace('Kỳ ', '')
                if not semester.isdigit(): semester = 1
                
                cid = to_uuid('class', class_code)
                tid = to_uuid('teacher', teacher_name) # Ensure exact match with 01
                
                # Assume assigned to first school for simplicity or derive from teacher
                class_map[class_code] = cid
                
                desc = subject + " (Học kỳ " + str(semester) + ")"
                
                out_lines.append(f"""
INSERT INTO public.classes (id, name, description, subject, teacher_id, academic_year) 
VALUES ({escape_sql(cid)}, {escape_sql(class_code + " - " + subject)}, {escape_sql(desc)}, {escape_sql(subject)}, {escape_sql(tid)}, {escape_sql(year)})
ON CONFLICT DO NOTHING;
""")

# -----------------
# 4. CLASS MEMBERS
# -----------------
with open(os.path.join(seed_dir, '04_class_members.md'), 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('|') and '---' not in line and 'STT' not in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 6:
                # STT | Sinh viên | Mã SV | ... | Lớp HP
                # Some tables have class in parts[5], let's check class names
                student_code = parts[2]
                class_code = parts[-1] # Usually last is class
                # Some rows have 'Số TC', we can just find class code
                
                # Verify class code
                if "DH" not in class_code and "SE" not in class_code and class_code not in class_map:
                    # Search through parts
                    for p in parts:
                        if p in class_map:
                            class_code = p
                            break
                
                sid = to_uuid('student', student_code)
                cid = to_uuid('class', class_code)
                
                out_lines.append(f"""
INSERT INTO public.class_members (class_id, student_id, status, role, joined_at)
VALUES ({escape_sql(cid)}, {escape_sql(sid)}, 'approved', 'student', now())
ON CONFLICT DO NOTHING;
""")

out_lines.append("COMMIT;")

output_file = os.path.join(seed_dir, '05_import.sql')
with open(output_file, 'w', encoding='utf-8') as f:
    f.write("\n".join(out_lines))

print(f"Generated {output_file} successfully!")
