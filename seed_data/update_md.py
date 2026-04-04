import re
import json
import os

def update_students_md(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out_lines = []
    in_table = False
    headers = []
    
    for line in lines:
        if line.startswith('<!--'):
            # fix mappings
            pass
            
        if '| STT |' in line:
            in_table = True
            line = line.replace('\n', '') + ' Metadata (JSON) |\n'
            # find indices
            parts = [p.strip() for p in line.split('|')[1:-1]]
            headers = parts
            out_lines.append(line)
            continue
            
        if in_table and '|---' in line:
            line = line.replace('\n', '') + '---|\n'
            out_lines.append(line)
            continue
            
        if in_table and line.startswith('|') and not '|---' in line:
            parts = [p.strip() for p in line.split('|')[1:-1]]
            if len(parts) >= 3:
                row_dict = dict(zip(headers, parts))
                ma_sv = row_dict.get('Mã SV', '')
                lop = row_dict.get('Lớp nhập học', '')
                
                metadata = {
                    "student_code": ma_sv,
                    "enrollment_class": lop,
                    "school": "ĐHSPKT Vinh"
                }
                
                # if there are columns missing in parts, pad them
                # we don't really have to, just append the metadata
                meta_json = json.dumps(metadata, ensure_ascii=False)
                new_line = line.replace('\n', '') + f' `{meta_json}` |\n'
                out_lines.append(new_line)
            else:
                out_lines.append(line)
        else:
            in_table = False
            # fix mapping comments
            if 'Ánh xạ Supabase:' in line:
                out_lines.append(line)
            elif '- Bảng: student_profiles' in line:
                out_lines.append("  - Bảng: public.profiles (role = 'student', metadata chứa thông tin thêm)\n")
            elif "- Bảng: users (role = 'student')" in line:
                out_lines.append("  - Bảng: auth.users (role = 'student')\n")
            else:
                out_lines.append(line)
                
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(out_lines)

def update_classes_md(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out_lines = []
    for line in lines:
        if '- Bảng: class_sections' in line:
            out_lines.append("  - Bảng: public.classes (mỗi dòng = 1 lớp học phần)\n")
        elif '- Columns: id, subject_code' in line:
            out_lines.append("  - Columns: id, school_id, teacher_id, name, subject, academic_year, class_settings (chứa lịch học, phòng học)\n")
        else:
            out_lines.append(line)
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(out_lines)

directory = r'd:\\code\\Flutter_Android\\Flutter_Android\\AI_LMS_PRD\\seed_data'
update_students_md(os.path.join(directory, '02_students.md'))
update_classes_md(os.path.join(directory, '03_classes.md'))
print("Updated successfully")
