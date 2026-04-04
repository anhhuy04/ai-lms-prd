import os

def fix_columns2(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    
    for line in lines:
        if line.strip().startswith('|') and not line.strip().startswith('|---'):
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 3 and parts[0] != 'STT': # skip header
                # We know the last two should be Email and Metadata.
                # Right now, parts[-1] is email, parts[-2] is metadata.
                # Let's swap them.
                if '@gmail.com' in parts[-1] or '@student' in parts[-1] or 'không có' in parts[-1]:
                    parts[-1], parts[-2] = parts[-2], parts[-1]
                    out.append('| ' + ' | '.join(parts) + ' |\n')
                    continue
        out.append(line)
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(out)

dir_path = r'd:\\code\\Flutter_Android\\Flutter_Android\\AI_LMS_PRD\\seed_data'
fix_columns2(os.path.join(dir_path, '02_students.md'))
print("Columns fixed 2")
