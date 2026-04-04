import os
import json

def process_students(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    headers = []
    in_table = False
    
    for line in lines:
        if line.startswith('<!--'):
            out.append(line)
        elif 'Bảng: users (role' in line:
            out.append("  - Bảng: auth.users (role = 'student')\n")
        elif 'Bảng: student_profiles' in line:
            out.append("  - Bảng: public.profiles (role = 'student', metadata chứa thông tin thêm: student_code, enrollment_class, school_name)\n")
        elif '| STT |' in line and not in_table:
            in_table = True
            headers = [h.strip() for h in line.strip().strip('|').split('|')]
            out.append(line.replace('\n', '') + ' Metadata (JSON) |\n')
        elif in_table and '|---' in line:
            out.append(line.replace('\n', '') + '---|\n')
        elif in_table and line.startswith('|') and not '|---' in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= len(headers):
                idx_ma_sv = headers.index('Mã SV') if 'Mã SV' in headers else -1
                idx_lop = headers.index('Lớp nhập học') if 'Lớp nhập học' in headers else -1
                
                ma_sv = parts[idx_ma_sv] if idx_ma_sv != -1 else ""
                lop = parts[idx_lop] if idx_lop != -1 else ""
                
                meta = {}
                if ma_sv: meta["student_code"] = ma_sv
                if lop: meta["enrollment_class"] = lop
                meta["school_name"] = "Trường Đại học Sư phạm Kỹ thuật Vinh"
                
                meta_str = json.dumps(meta, ensure_ascii=False)
                out.append(line.replace('\n', '') + f' `{meta_str}` |\n')
            else:
                out.append(line)
        elif in_table and not line.strip().startswith('|'):
            in_table = False
            out.append(line)
        else:
            out.append(line)
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(out)

def process_classes(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    for line in lines:
        if 'Bảng: class_sections' in line:
            out.append("  - Bảng: public.classes (mỗi dòng = 1 lớp học phần)\n")
        elif 'Columns: id, subject_code' in line:
            out.append("  - Columns: id, school_id, teacher_id, name, subject, academic_year, class_settings (chứa lịch học, phòng học)\n")
        else:
            out.append(line)
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(out)

dir_path = r'd:\\code\\Flutter_Android\\Flutter_Android\\AI_LMS_PRD\\seed_data'
process_students(os.path.join(dir_path, '02_students.md'))
process_classes(os.path.join(dir_path, '03_classes.md'))
print("Done")
