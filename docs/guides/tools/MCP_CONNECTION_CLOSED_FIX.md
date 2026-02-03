# Hướng dẫn Sửa Lỗi MCP "Connection closed" (Error -32000)

## 🔍 Quy trình Chẩn đoán Tự động

### Bước 1: Thu thập Log từ Developer Tools

1. **Mở Developer Tools:**
   - Nhấn `Ctrl + Shift + I` (Windows/Linux) hoặc `Cmd + Option + I` (macOS)
   - Hoặc: Menu **Help** → **Toggle Developer Tools**

2. **Chuyển sang tab Console:**
   - Click tab **Console** trong Developer Tools

3. **Filter log MCP:**
   - Trong ô Filter, gõ: `mcp` hoặc `MCP` hoặc `transport` hoặc `connection`
   - Hoặc filter chi tiết: `mcp|MCP|transport|connection|closed|32000`

4. **Restart Cursor để xem log khởi động:**
   - Đóng Developer Tools
   - Đóng hoàn toàn Cursor (File → Exit)
   - Mở lại Cursor
   - Mở Developer Tools ngay (`Ctrl + Shift + I`)
   - Xem Console với filter `mcp`

5. **Copy tất cả log liên quan:**
   - Chọn tất cả log (click đầu, scroll xuống cuối, giữ Shift và click cuối)
   - Copy (`Ctrl + C`)
   - **Dán vào chat với AI Agent để phân tích**

---

## 🔧 Bước 2: Kiểm tra File Cấu hình MCP

### Vị trí file mcp.json trên Windows:

```
C:\Users\<username>\.cursor\mcp.json
```

Hoặc:
```
%APPDATA%\Cursor\mcp.json
```

### Kiểm tra các điểm sau:

#### ✅ 1. Đường dẫn Windows (Backslashes)

**SAI:**
```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "D:/code/Flutter_Android/AI_LMS_PRD"  // ❌ Forward slashes
      ]
    }
  }
}
```

**ĐÚNG:**
```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "D:\\code\\Flutter_Android\\AI_LMS_PRD"  // ✅ Double backslashes cho JSON
      ]
    }
  }
}
```

**HOẶC:**
```json
{
  "mcpServers": {
    "filesystem": {
      "args": [
        "D:/code/Flutter_Android/AI_LMS_PRD"  // ✅ Forward slashes cũng OK trong args
      ]
    }
  }
}
```

#### ✅ 2. Kiểm tra File Thực thi Tồn tại

**Supabase MCP (Python):**
```powershell
# Kiểm tra Python
python --version
# Hoặc
python3 --version

# Kiểm tra pipx
pipx list | findstr supabase-mcp-server

# Kiểm tra uv
uv --version
```

**NPM-based MCP (npx):**
```powershell
# Kiểm tra Node.js
node --version

# Kiểm tra npx
npx --version

# Test chạy trực tiếp
npx -y @supabase/mcp-server-supabase@latest
```

#### ✅ 3. Kiểm tra Biến Môi trường

**Supabase MCP cần:**
- `QUERY_API_KEY` - **BẮT BUỘC** (lấy từ https://thequery.dev)
- `SUPABASE_PROJECT_REF` - **BẮT BUỘC**
- `SUPABASE_DB_PASSWORD` - **BẮT BUỘC**
- `SUPABASE_REGION` - **BẮT BUỘC** (mặc định: `us-east-1`)
- `SUPABASE_ACCESS_TOKEN` - Tùy chọn (cho Management API)
- `SUPABASE_SERVICE_ROLE_KEY` - Tùy chọn (cho Auth Admin SDK)

**Kiểm tra trong PowerShell:**
```powershell
# Kiểm tra từng biến
$env:QUERY_API_KEY
$env:SUPABASE_PROJECT_REF
$env:SUPABASE_DB_PASSWORD
$env:SUPABASE_REGION
```

---

## 📋 Bước 3: Kiểm tra Xung đột Rules

### Đọc các file rules:

1. `.clinerules` - File trung tâm điều phối
2. `.cursorrules` (nếu có) - Rules cho Cursor
3. Các file markdown trong `docs/` có thể chứa quy tắc

### Tìm kiếm các quy tắc có thể chặn:

```powershell
# Tìm trong .clinerules
Select-String -Path ".clinerules" -Pattern "terminal|command|execute|block|deny|prevent" -CaseSensitive:$false

# Tìm trong docs
Get-ChildItem -Path "docs" -Recurse -Filter "*.md" | Select-String -Pattern "terminal|command|execute|block" -CaseSensitive:$false
```

---

## 🛠️ Bước 4: File Cấu hình MCP.json Mẫu (Windows)

### File mcp.json Hoàn chỉnh và Đúng chuẩn:

```json
{
  "mcpServers": {
    "supabase-official": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "your-access-token-here",
        "SUPABASE_PROJECT_REF": "your-project-ref-here"
      }
    },
    "supabase": {
      "command": "supabase-mcp-server",
      "env": {
        "QUERY_API_KEY": "your-query-api-key-from-thequery.dev",
        "SUPABASE_PROJECT_REF": "your-project-ref",
        "SUPABASE_DB_PASSWORD": "your-db-password",
        "SUPABASE_REGION": "us-east-1",
        "SUPABASE_ACCESS_TOKEN": "your-access-token",
        "SUPABASE_SERVICE_ROLE_KEY": "your-service-role-key"
      }
    },
    "github.com/upstash/context7-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp@latest"
      ],
      "env": {
        "CONTEXT7_API_KEY": "your-context7-api-key"
      }
    },
    "github.com/zcaceres/fetch-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@zcaceres/fetch-mcp@latest"
      ]
    },
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github@latest"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem@latest",
        "D:\\code\\Flutter_Android\\AI_LMS_PRD"
      ]
    },
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory@latest"
      ]
    },
    "dart": {
      "command": "dart",
      "args": [
        "run",
        "mcp_server_dart"
      ]
    }
  }
}
```

### Lưu ý Quan trọng:

1. **Đường dẫn Windows:**
   - Sử dụng double backslashes `\\` trong JSON string
   - Hoặc forward slashes `/` (cũng hoạt động)

2. **Supabase MCP (Python):**
   - Nếu dùng `pipx install supabase-mcp-server`, dùng:
     ```json
     "command": "supabase-mcp-server"
     ```
   - Nếu dùng `uv pip install`, dùng:
     ```json
     "command": "uv",
     "args": ["run", "supabase-mcp-server"]
     ```
   - Tìm full path:
     ```powershell
     where.exe supabase-mcp-server
     # Hoặc
     Get-Command supabase-mcp-server | Select-Object -ExpandProperty Source
     ```

3. **Kiểm tra Full Path cho Python MCP:**
   ```powershell
   # Tìm pipx
   where.exe pipx
   pipx list | findstr supabase
   
   # Tìm uv
   where.exe uv
   
   # Nếu không tìm thấy, dùng full path:
   # C:\Users\<username>\.local\bin\supabase-mcp-server.exe
   # Hoặc
   # C:\Users\<username>\AppData\Local\pipx\venvs\supabase-mcp-server\Scripts\supabase-mcp-server.exe
   ```

---

## 🔨 Bước 5: Lệnh Terminal để Khôi phục

### 1. Cài đặt Prerequisites

```powershell
# Kiểm tra Node.js
node --version
# Nếu chưa có: Tải từ https://nodejs.org/

# Kiểm tra Python
python --version
# Nếu chưa có: Tải từ https://www.python.org/downloads/

# Kiểm tra pipx (cho Python packages)
pipx --version
# Nếu chưa có:
python -m pip install --user pipx
python -m pipx ensurepath
```

### 2. Cài đặt Supabase MCP (Python)

```powershell
# Cách 1: Dùng pipx (Khuyến nghị)
pipx install supabase-mcp-server

# Cách 2: Dùng uv
uv pip install supabase-mcp-server

# Kiểm tra cài đặt
where.exe supabase-mcp-server
# Hoặc
Get-Command supabase-mcp-server
```

### 3. Test MCP Server Trực tiếp

```powershell
# Test Supabase MCP (Python)
supabase-mcp-server

# Test Supabase MCP (NPM)
npx -y @supabase/mcp-server-supabase@latest

# Nếu có lỗi, sẽ hiển thị error message
```

### 4. Tạo/Cập nhật File mcp.json

```powershell
# Tạo thư mục nếu chưa có
New-Item -ItemType Directory -Force -Path "$env:APPDATA\Cursor"

# Mở file để chỉnh sửa
notepad "$env:APPDATA\Cursor\mcp.json"
# Hoặc
code "$env:APPDATA\Cursor\mcp.json"
```

### 5. Set Environment Variables (Nếu cần)

```powershell
# Set cho session hiện tại
$env:QUERY_API_KEY = "your-api-key"
$env:SUPABASE_PROJECT_REF = "your-project-ref"
$env:SUPABASE_DB_PASSWORD = "your-db-password"
$env:SUPABASE_REGION = "us-east-1"

# Set vĩnh viễn (User-level)
[System.Environment]::SetEnvironmentVariable("QUERY_API_KEY", "your-api-key", "User")
[System.Environment]::SetEnvironmentVariable("SUPABASE_PROJECT_REF", "your-project-ref", "User")
[System.Environment]::SetEnvironmentVariable("SUPABASE_DB_PASSWORD", "your-db-password", "User")
[System.Environment]::SetEnvironmentVariable("SUPABASE_REGION", "us-east-1", "User")
```

---

## 🎯 Bước 6: Nguyên nhân Thường gặp và Giải pháp

### Nguyên nhân 1: Command không tìm thấy (ENOENT)

**Lỗi:** `spawn ENOENT` hoặc `Command not found`

**Giải pháp:**
1. Tìm full path của command:
   ```powershell
   where.exe supabase-mcp-server
   where.exe python
   where.exe npx
   ```
2. Dùng full path trong mcp.json:
   ```json
   "command": "C:\\Users\\username\\.local\\bin\\supabase-mcp-server.exe"
   ```

### Nguyên nhân 2: Thiếu Environment Variables

**Lỗi:** `Missing environment variable: QUERY_API_KEY`

**Giải pháp:**
1. Thêm vào `env` section trong mcp.json
2. Hoặc set trong System Environment Variables
3. Hoặc tạo file `.env` tại:
   - Windows: `%APPDATA%\supabase-mcp\.env`

### Nguyên nhân 3: Connection Timeout

**Lỗi:** `Connection timeout` hoặc `Connection closed`

**Giải pháp:**
1. Kiểm tra internet connection
2. Kiểm tra Supabase project còn hoạt động
3. Kiểm tra `SUPABASE_REGION` có đúng không
4. Kiểm tra firewall không chặn connection

### Nguyên nhân 4: Python Path sai

**Lỗi:** `python: command not found`

**Giải pháp:**
1. Kiểm tra Python trong PATH:
   ```powershell
   $env:PATH -split ';' | Select-String python
   ```
2. Thêm Python vào PATH nếu chưa có
3. Hoặc dùng full path:
   ```json
   "command": "C:\\Python312\\python.exe",
   "args": ["-m", "supabase_mcp_server"]
   ```

### Nguyên nhân 5: JSON Syntax Error

**Lỗi:** `Unexpected token` hoặc `JSON parse error`

**Giải pháp:**
1. Validate JSON:
   ```powershell
   Get-Content "$env:APPDATA\Cursor\mcp.json" | ConvertFrom-Json
   ```
2. Kiểm tra:
   - Dấu phẩy cuối cùng
   - Dấu ngoặc nhọn đóng mở đúng
   - Escape characters (`\\` cho backslash)

---

## 📝 Checklist Hoàn chỉnh

Sử dụng checklist này để đảm bảo không bỏ sót:

- [ ] **Thu thập Log:**
  - [ ] Mở Developer Tools (`Ctrl + Shift + I`)
  - [ ] Filter `mcp` trong Console
  - [ ] Restart Cursor và xem log khởi động
  - [ ] Copy tất cả log liên quan

- [ ] **Kiểm tra File Cấu hình:**
  - [ ] File `mcp.json` tồn tại tại đúng vị trí
  - [ ] JSON syntax đúng (validate bằng PowerShell)
  - [ ] Đường dẫn Windows đúng format (`\\` hoặc `/`)
  - [ ] Tất cả `command` và `args` đúng

- [ ] **Kiểm tra Prerequisites:**
  - [ ] Node.js đã cài (`node --version`)
  - [ ] npx hoạt động (`npx --version`)
  - [ ] Python đã cài (`python --version`)
  - [ ] pipx hoặc uv đã cài (nếu dùng Supabase MCP Python)

- [ ] **Kiểm tra Commands:**
  - [ ] Tìm full path của tất cả commands (`where.exe`)
  - [ ] Test chạy trực tiếp từ terminal
  - [ ] Kiểm tra không có lỗi khi chạy standalone

- [ ] **Kiểm tra Environment Variables:**
  - [ ] Tất cả biến cần thiết đã set trong `env` section
  - [ ] Hoặc đã set trong System Environment Variables
  - [ ] Hoặc đã tạo file `.env` tại đúng vị trí

- [ ] **Kiểm tra Xung đột:**
  - [ ] Đọc `.clinerules` và `.cursorrules`
  - [ ] Tìm các quy tắc có thể chặn terminal/command execution
  - [ ] Kiểm tra không có rules conflict

- [ ] **Test Sau khi Sửa:**
  - [ ] Restart Cursor hoàn toàn
  - [ ] Mở Developer Tools và xem log
  - [ ] Test từng MCP server bằng cách yêu cầu AI Agent
  - [ ] Ghi nhận kết quả

---

## 🚀 Quick Fix Script (PowerShell)

Chạy script này để tự động kiểm tra và sửa một số lỗi phổ biến:

```powershell
# MCP Connection Closed - Quick Fix Script
# Chạy với quyền Administrator nếu cần

Write-Host "=== MCP Connection Closed - Quick Fix ===" -ForegroundColor Cyan

# 1. Kiểm tra Prerequisites
Write-Host "`n1. Kiểm tra Prerequisites..." -ForegroundColor Yellow
$nodeVersion = node --version 2>$null
$pythonVersion = python --version 2>$null
$npxVersion = npx --version 2>$null

if ($nodeVersion) {
    Write-Host "   ✓ Node.js: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "   ✗ Node.js chưa cài đặt" -ForegroundColor Red
    Write-Host "     Tải từ: https://nodejs.org/" -ForegroundColor Yellow
}

if ($pythonVersion) {
    Write-Host "   ✓ Python: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "   ✗ Python chưa cài đặt" -ForegroundColor Red
    Write-Host "     Tải từ: https://www.python.org/downloads/" -ForegroundColor Yellow
}

if ($npxVersion) {
    Write-Host "   ✓ npx: $npxVersion" -ForegroundColor Green
} else {
    Write-Host "   ✗ npx không hoạt động" -ForegroundColor Red
}

# 2. Kiểm tra File mcp.json
Write-Host "`n2. Kiểm tra File mcp.json..." -ForegroundColor Yellow
$mcpJsonPath = "$env:APPDATA\Cursor\mcp.json"

if (Test-Path $mcpJsonPath) {
    Write-Host "   ✓ File tồn tại: $mcpJsonPath" -ForegroundColor Green
    
    # Validate JSON
    try {
        $json = Get-Content $mcpJsonPath | ConvertFrom-Json
        Write-Host "   ✓ JSON syntax đúng" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ JSON syntax SAI: $_" -ForegroundColor Red
        Write-Host "     Sửa lỗi JSON trước khi tiếp tục" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ File không tồn tại: $mcpJsonPath" -ForegroundColor Red
    Write-Host "     Tạo file mcp.json mới..." -ForegroundColor Yellow
    # Tạo file mẫu (cần user điền thông tin)
}

# 3. Kiểm tra Commands
Write-Host "`n3. Kiểm tra Commands..." -ForegroundColor Yellow
$commands = @("npx", "python", "supabase-mcp-server")
foreach ($cmd in $commands) {
    $path = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($path) {
        Write-Host "   ✓ $cmd : $($path.Source)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $cmd không tìm thấy trong PATH" -ForegroundColor Red
    }
}

# 4. Kiểm tra Environment Variables
Write-Host "`n4. Kiểm tra Environment Variables..." -ForegroundColor Yellow
$requiredVars = @("QUERY_API_KEY", "SUPABASE_PROJECT_REF", "SUPABASE_DB_PASSWORD")
foreach ($var in $requiredVars) {
    $value = [System.Environment]::GetEnvironmentVariable($var, "User")
    if ($value) {
        Write-Host "   ✓ $var đã set" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $var chưa set" -ForegroundColor Red
    }
}

Write-Host "`n=== Hoàn thành ===" -ForegroundColor Cyan
Write-Host "Nếu có lỗi, hãy sửa theo hướng dẫn ở trên" -ForegroundColor Yellow
```

---

## 📞 Hỗ trợ

Nếu vẫn gặp lỗi sau khi làm theo hướng dẫn:

1. **Copy toàn bộ log từ Developer Tools Console**
2. **Copy nội dung file mcp.json** (ẩn sensitive data)
3. **Gửi cho AI Agent** kèm mô tả chi tiết vấn đề
4. AI Agent sẽ phân tích và đưa ra giải pháp cụ thể

---

## 📚 Tài liệu Tham khảo

- [MCP_DEBUG_GUIDE.md](./MCP_DEBUG_GUIDE.md) - Hướng dẫn debug chi tiết
- [MCP_GUIDE.md](../../ai/MCP_GUIDE.md) - Hướng dẫn sử dụng từng MCP server
- [CURSOR_SETUP.md](../../ai/CURSOR_SETUP.md) - Hướng dẫn setup Cursor và MCP
- [Supabase MCP Server README](https://github.com/alexander-zuev/supabase-mcp-server) - Documentation chính thức
