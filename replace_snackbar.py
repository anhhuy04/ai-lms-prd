import re
import sys

def replace_snackbars(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Xóa ScaffoldMessenger.of(context).hideCurrentSnackBar();
    content = re.sub(r'ScaffoldMessenger\.of\(context\)\.hideCurrentSnackBar\(\);\s*', '', content)

    # Thay thế ScaffoldMessenger
    # Khớp toàn bộ ScaffoldMessenger.of(context).showSnackBar(...);
    # Bằng cách sử dụng parse ngoặc.
    
    out = []
    i = 0
    while i < len(content):
        match = re.search(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(', content[i:])
        if not match:
            out.append(content[i:])
            break
            
        start_idx = i + match.start()
        out.append(content[i:start_idx])
        
        # Tìm dấu ngoặc đóng của showSnackBar(
        open_brackets = 1
        curr_idx = start_idx + match.end()
        while curr_idx < len(content) and open_brackets > 0:
            if content[curr_idx] == '(':
                open_brackets += 1
            elif content[curr_idx] == ')':
                open_brackets -= 1
            curr_idx += 1
            
        # Tìm dấu chấm phẩy
        while curr_idx < len(content) and content[curr_idx] in [' ', '\n', '\t']:
            curr_idx += 1
        if curr_idx < len(content) and content[curr_idx] == ';':
            curr_idx += 1
            
        block = content[start_idx:curr_idx]
        
        # Trích xuất màu nền để biết loại toast (error, warning, success, info)
        toast_type = 'info'
        if 'DesignColors.error' in block or 'Colors.red' in block:
            toast_type = 'error'
        elif 'DesignColors.warning' in block or 'Colors.orange' in block:
            toast_type = 'warning'
        elif 'Colors.green' in block or 'DesignColors.success' in block:
            toast_type = 'success'
            
        # Trích xuất nội dung text
        text_match = re.search(r"Text\(\s*(['\"].*?['\"]|e\.toString\(\).*?|.*?)\s*\)", block, flags=re.DOTALL)
        if text_match:
            text_val = text_match.group(1).strip()
            # Bỏ padding dư nếu cần
            out.append(f'AppToast.{toast_type}(context, {text_val});')
        else:
            # Fallback nếu không parse được Text
            out.append(f"AppToast.{toast_type}(context, 'Thông báo');")
            
        i = curr_idx

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write("".join(out))
    
    print(f"Done replacing in {file_path}")

if __name__ == '__main__':
    replace_snackbars('lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart')
