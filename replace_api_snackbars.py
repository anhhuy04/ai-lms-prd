import re
import sys

def replace_api_key_snackbars(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Xóa ScaffoldMessenger.of(context).hideCurrentSnackBar();
    content = re.sub(r'ScaffoldMessenger\.of\(context\)\.hideCurrentSnackBar\(\);\s*', '', content)

    out = []
    i = 0
    while i < len(content):
        match = re.search(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(', content[i:])
        if not match:
            out.append(content[i:])
            break
            
        start_idx = i + match.start()
        out.append(content[i:start_idx])
        
        open_brackets = 1
        curr_idx = start_idx + match.end()
        while curr_idx < len(content) and open_brackets > 0:
            if content[curr_idx] == '(':
                open_brackets += 1
            elif content[curr_idx] == ')':
                open_brackets -= 1
            curr_idx += 1
            
        while curr_idx < len(content) and content[curr_idx] in [' ', '\n', '\t']:
            curr_idx += 1
        if curr_idx < len(content) and content[curr_idx] == ';':
            curr_idx += 1
            
        block = content[start_idx:curr_idx]
        
        toast_type = 'info'
        if 'DesignColors.error' in block or 'Colors.red' in block:
            toast_type = 'error'
        elif 'DesignColors.warning' in block or 'Colors.orange' in block:
            toast_type = 'warning'
        elif 'Colors.green' in block or 'DesignColors.success' in block or '✅' in block:
            toast_type = 'success'
            
        text_match = re.search(r"Text\(\s*(['\"].*?['\"]|e\.toString\(\).*?|.*?)\s*\)", block, flags=re.DOTALL)
        if text_match:
            text_val = text_match.group(1).strip()
            if text_val.startswith("const "):
                text_val = text_val[6:]
            out.append(f'AppToast.{toast_type}(context, {text_val});')
        else:
            out.append(f"AppToast.{toast_type}(context, 'Thông báo');")
            
        i = curr_idx

    # Ensure AppToast import is present
    result = "".join(out)
    if "import 'package:ai_mls/widgets/toast/app_toast.dart';" not in result:
        result = result.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:ai_mls/widgets/toast/app_toast.dart';")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(result)
    
    print(f"Done replacing in {file_path}")

if __name__ == '__main__':
    replace_api_key_snackbars('lib/presentation/views/settings/api_key_setup_screen.dart')
