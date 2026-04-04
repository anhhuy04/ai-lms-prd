import os
import re
import unicodedata

def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    # Remove diacritics
    return u"".join([c for c in nfkd_form if not unicodedata.combining(c)])

def generate_email(full_name, seen_emails):
    # Remove specific vietnamese d
    clean_name = full_name.replace('Đ', 'D').replace('đ', 'd')
    clean_name = remove_accents(clean_name).strip()
    words = [w.lower() for w in clean_name.split() if w]
    
    if len(words) >= 2:
        base = words[-2] + words[-1]
    elif len(words) == 1:
        base = words[0]
    else:
        base = "student"
        
    base = re.sub(r'[^a-z0-9]', '', base)
    
    email = f"{base}@gmail.com"
    original_base = base
    counter = 1
    while email in seen_emails:
        email = f"{base}{counter}@gmail.com"
        counter += 1
        
    seen_emails.add(email)
    return email

def process_students(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    headers = []
    in_table = False
    seen_emails = set()
    
    for line in lines:
        if '| STT |' in line and not in_table:
            in_table = True
            headers = [h.strip() for h in line.strip().strip('|').split('|')]
            meta_idx = headers.index('Metadata (JSON)') if 'Metadata (JSON)' in headers else len(headers)
            headers.insert(meta_idx, 'Email')
            out.append('| ' + ' | '.join(headers) + ' |\n')
            continue
            
        if in_table and '|---' in line:
            out.append('|' + '|'.join(['---' for _ in headers]) + '|\n')
            continue
            
        if in_table and line.startswith('|') and not '|---' in line:
            parts = [p.strip() for p in line.strip().strip('|').split('|')]
            
            # Since parts is length of old headers, let's insert email at metadat_idx
            if len(parts) >= len(headers) - 1:
                name_idx = headers.index('Họ và tên') if 'Họ và tên' in headers else -1
                name = parts[name_idx] if name_idx != -1 else ""
                
                email = generate_email(name, seen_emails)
                
                meta_idx = headers.index('Metadata (JSON)')
                parts.insert(meta_idx, email)
                
                out.append('| ' + ' | '.join(parts) + ' |\n')
            else:
                out.append(line)
                
        elif in_table and not line.strip().startswith('|'):
            in_table = False
            out.append(line)
        else:
            out.append(line)
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(out)

dir_path = r'd:\\code\\Flutter_Android\\Flutter_Android\\AI_LMS_PRD\\seed_data'
process_students(os.path.join(dir_path, '02_students.md'))
print("Emails generated successfully")
