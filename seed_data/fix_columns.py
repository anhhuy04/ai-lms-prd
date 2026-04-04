import os

def fix_columns(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    
    for line in lines:
        if line.strip().startswith('|') and not line.strip().startswith('|---'):
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            if len(parts) >= 2:
                # If the second to last part is JSON and last is email
                if parts[-2].startswith('{"') and '@gmail.com' in parts[-1] or '@student' in parts[-1] or 'không có' in parts[-1]:
                    # Swap them
                    parts[-1], parts[-2] = parts[-2], parts[-1]
                    out.append('| ' + ' | '.join(parts) + ' |\n')
                    continue
                # Or if the header is Email and Metadata
                elif parts[-2] == 'Email' and parts[-1] == 'Metadata (JSON)':
                    # Headers are correct
                    pass
        out.append(line)
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(out)

dir_path = r'd:\\code\\Flutter_Android\\Flutter_Android\\AI_LMS_PRD\\seed_data'
fix_columns(os.path.join(dir_path, '02_students.md'))
print("Columns fixed")
