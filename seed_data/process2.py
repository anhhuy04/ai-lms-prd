import os
import json

def process_teachers(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    headers = []
    in_table = False
    
    for line in lines:
        if 'Bảng: users' in line and "teacher" in line:
            out.append("  - Bảng: auth.users (role = 'teacher', 14 records)\n")
        elif 'Bảng: teacher_profiles' in line:
            out.append("  - Bảng: public.profiles (role = 'teacher', metadata chứa school_name, degree_title)\n")
        elif 'Bảng: subject_assignments' in line:
            out.append("  - Ghi chú: Lưu thông tin môn học phụ trách vào metadata hoặc bảng liên kết.\n")
        elif '| STT |' in line and 'Họ và tên' in line and not in_table:
            in_table = True
            headers = [h.strip() for h in line.strip().strip('|').split('|')]
            out.append(line.replace('\n', '') + ' Metadata (JSON) |\n')
        elif in_table and '|---' in line:
            out.append(line.replace('\n', '') + '---|\n')
        elif in_table and line.startswith('|') and not '|---' in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= len(headers):
                idx_degree = headers.index('Học vị / Chức vụ') if 'Học vị / Chức vụ' in headers else -1
                degree = parts[idx_degree] if idx_degree != -1 else ""
                
                meta = {}
                meta["school_name"] = "Trường Đại học Sư phạm Kỹ thuật Vinh"
                if degree: meta["degree_title"] = degree
                
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

def process_class_members(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    for line in lines:
        if 'Bảng: class_enrollments' in line:
            out.append("  - Bảng: public.class_members\n")
        elif 'Columns: id, class_section_id (FK→class_sections), student_id (FK→users)' in line:
            out.append("  - Columns: class_id (FK→public.classes), student_id (FK→auth.users)\n")
        else:
            out.append(line)
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(out)

dir_path = r'd:\\code\\Flutter_Android\\Flutter_Android\\AI_LMS_PRD\\seed_data'
process_teachers(os.path.join(dir_path, '01_school_and_teachers.md'))
process_class_members(os.path.join(dir_path, '04_class_members.md'))
print("Done processing teachers and class members")
