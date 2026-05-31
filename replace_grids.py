import os
import re

files_to_update = [
    r'lib/presentation/views/assignment/teacher/widgets/drawer/create_assignment_drawer.dart',
    r'lib/presentation/views/class/teacher/create_class_screen.dart',
    r'lib/presentation/views/class/teacher/teacher_assignment_detail_screen.dart',
    r'lib/presentation/views/grading/student_analytics_screen.dart',
    r'lib/presentation/views/grading/teacher_student_analytics_screen.dart',
    r'lib/presentation/views/settings/widgets/export_template_bottom_sheet.dart',
    r'lib/widgets/loading/shimmer_loading.dart'
]

def replace_grid(file_path):
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return
        
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Replace GridView.count with GridView.extent
    # and crossAxisCount: X with maxCrossAxisExtent: 180
    
    # We will use regex to find GridView.count(
    # and then inside its parameters replace crossAxisCount: \d+ with maxCrossAxisExtent: 180
    
    # Simple substitution strategy:
    # 1. Replace "GridView.count(" with "GridView.extent("
    # 2. Replace "crossAxisCount: 2," with "maxCrossAxisExtent: 200,"
    # 3. Replace "crossAxisCount: 3," with "maxCrossAxisExtent: 150,"
    # 4. Replace "crossAxisCount: 4," with "maxCrossAxisExtent: 120,"
    
    new_content = content.replace('GridView.count(', 'GridView.extent(')
    new_content = re.sub(r'crossAxisCount:\s*2\s*,?', 'maxCrossAxisExtent: 240,', new_content)
    new_content = re.sub(r'crossAxisCount:\s*3\s*,?', 'maxCrossAxisExtent: 160,', new_content)
    new_content = re.sub(r'crossAxisCount:\s*4\s*,?', 'maxCrossAxisExtent: 120,', new_content)
    
    # Sometimes crossAxisCount might just be written without comma at the end, regex handles it roughly
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Updated {file_path}")

for f in files_to_update:
    replace_grid(f)
