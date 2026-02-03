# MCP Connection Closed - Auto Fix Script
# Chạy script này để tự động kiểm tra và sửa lỗi MCP "Connection closed" (Error -32000)

param(
    [switch]$Fix,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

Write-Host "=== MCP Connection Closed - Diagnostic & Fix Tool ===" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. KIỂM TRA PREREQUISITES
# ============================================
Write-Host "[1/6] Kiểm tra Prerequisites..." -ForegroundColor Yellow

$prereqs = @{
    "Node.js" = @{ Command = "node"; Args = @("--version"); Required = $true }
    "Python" = @{ Command = "python"; Args = @("--version"); Required = $false }
    "npx" = @{ Command = "npx"; Args = @("--version"); Required = $true }
    "pipx" = @{ Command = "pipx"; Args = @("--version"); Required = $false }
}

$prereqResults = @{}
foreach ($name in $prereqs.Keys) {
    $prereq = $prereqs[$name]
    try {
        $output = & $prereq.Command $prereq.Args 2>&1
        if ($LASTEXITCODE -eq 0 -or $output) {
            Write-Host "  ✓ $name : $($output -join ' ')" -ForegroundColor Green
            $prereqResults[$name] = @{ Installed = $true; Path = (Get-Command $prereq.Command -ErrorAction SilentlyContinue).Source }
        } else {
            throw "Command failed"
        }
    } catch {
        if ($prereq.Required) {
            Write-Host "  ✗ $name : CHƯA CÀI ĐẶT (BẮT BUỘC)" -ForegroundColor Red
            Write-Host "    → Tải từ: https://nodejs.org/" -ForegroundColor Yellow
        } else {
            Write-Host "  ⚠ $name : Chưa cài đặt (Tùy chọn)" -ForegroundColor Yellow
        }
        $prereqResults[$name] = @{ Installed = $false; Path = $null }
    }
}

# ============================================
# 2. KIỂM TRA FILE MCP.JSON
# ============================================
Write-Host "`n[2/6] Kiểm tra File mcp.json..." -ForegroundColor Yellow

$mcpJsonPath = "$env:APPDATA\Cursor\mcp.json"
$mcpJsonExists = Test-Path $mcpJsonPath

if ($mcpJsonExists) {
    Write-Host "  ✓ File tồn tại: $mcpJsonPath" -ForegroundColor Green
    
    try {
        $jsonContent = Get-Content $mcpJsonPath -Raw
        $json = $jsonContent | ConvertFrom-Json
        Write-Host "  ✓ JSON syntax đúng" -ForegroundColor Green
        
        # Kiểm tra cấu trúc
        if ($json.mcpServers) {
            Write-Host "  ✓ Cấu trúc mcpServers đúng" -ForegroundColor Green
            $serverCount = ($json.mcpServers.PSObject.Properties | Measure-Object).Count
            Write-Host "  → Tìm thấy $serverCount MCP server(s)" -ForegroundColor Cyan
        } else {
            Write-Host "  ✗ Thiếu cấu trúc mcpServers" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ JSON syntax SAI: $_" -ForegroundColor Red
        Write-Host "    → Sửa lỗi JSON trước khi tiếp tục" -ForegroundColor Yellow
        $mcpJsonExists = $false
    }
} else {
    Write-Host "  ✗ File không tồn tại: $mcpJsonPath" -ForegroundColor Red
    Write-Host "    → Sẽ tạo file mẫu nếu dùng -Fix" -ForegroundColor Yellow
}

# ============================================
# 3. KIỂM TRA COMMANDS TRONG MCP.JSON
# ============================================
Write-Host "`n[3/6] Kiểm tra Commands trong mcp.json..." -ForegroundColor Yellow

if ($mcpJsonExists -and $json.mcpServers) {
    foreach ($serverName in $json.mcpServers.PSObject.Properties.Name) {
        $server = $json.mcpServers.$serverName
        $command = $server.command
        
        Write-Host "  Server: $serverName" -ForegroundColor Cyan
        Write-Host "    Command: $command" -ForegroundColor Gray
        
        # Kiểm tra command có tồn tại không
        try {
            if ($command -match "^[a-zA-Z0-9_-]+$") {
                # Command đơn giản, tìm trong PATH
                $cmdPath = Get-Command $command -ErrorAction SilentlyContinue
                if ($cmdPath) {
                    Write-Host "    ✓ Tìm thấy: $($cmdPath.Source)" -ForegroundColor Green
                } else {
                    Write-Host "    ✗ Không tìm thấy trong PATH" -ForegroundColor Red
                    Write-Host "      → Cần dùng full path hoặc cài đặt command" -ForegroundColor Yellow
                }
            } else {
                # Full path hoặc command phức tạp
                if (Test-Path $command) {
                    Write-Host "    ✓ File tồn tại: $command" -ForegroundColor Green
                } else {
                    Write-Host "    ⚠ Không kiểm tra được (có thể là full path hoặc command phức tạp)" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "    ⚠ Lỗi khi kiểm tra: $_" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  ⚠ Không thể kiểm tra (file không tồn tại hoặc JSON sai)" -ForegroundColor Yellow
}

# ============================================
# 4. KIỂM TRA ENVIRONMENT VARIABLES
# ============================================
Write-Host "`n[4/6] Kiểm tra Environment Variables..." -ForegroundColor Yellow

$requiredVars = @(
    @{ Name = "QUERY_API_KEY"; Description = "Supabase MCP (Python) - Lấy từ https://thequery.dev" }
    @{ Name = "SUPABASE_PROJECT_REF"; Description = "Supabase Project Reference ID" }
    @{ Name = "SUPABASE_DB_PASSWORD"; Description = "Supabase Database Password" }
    @{ Name = "SUPABASE_REGION"; Description = "Supabase Region (mặc định: us-east-1)" }
)

$optionalVars = @(
    @{ Name = "SUPABASE_ACCESS_TOKEN"; Description = "Supabase Management API Token" }
    @{ Name = "SUPABASE_SERVICE_ROLE_KEY"; Description = "Supabase Service Role Key" }
    @{ Name = "GITHUB_PERSONAL_ACCESS_TOKEN"; Description = "GitHub Personal Access Token" }
    @{ Name = "CONTEXT7_API_KEY"; Description = "Context7 API Key" }
)

Write-Host "  Required Variables:" -ForegroundColor Cyan
foreach ($var in $requiredVars) {
    $value = [System.Environment]::GetEnvironmentVariable($var.Name, "User")
    $processValue = [System.Environment]::GetEnvironmentVariable($var.Name, "Process")
    
    if ($value -or $processValue) {
        $displayValue = if ($value) { $value } else { $processValue }
        $maskedValue = if ($displayValue.Length -gt 8) { 
            $displayValue.Substring(0, 4) + "..." + $displayValue.Substring($displayValue.Length - 4)
        } else { 
            "***" 
        }
        Write-Host "    ✓ $($var.Name) : $maskedValue" -ForegroundColor Green
    } else {
        Write-Host "    ✗ $($var.Name) : CHƯA SET" -ForegroundColor Red
        Write-Host "      → $($var.Description)" -ForegroundColor Gray
    }
}

Write-Host "  Optional Variables:" -ForegroundColor Cyan
foreach ($var in $optionalVars) {
    $value = [System.Environment]::GetEnvironmentVariable($var.Name, "User")
    $processValue = [System.Environment]::GetEnvironmentVariable($var.Name, "Process")
    
    if ($value -or $processValue) {
        Write-Host "    ✓ $($var.Name) : Đã set" -ForegroundColor Green
    } else {
        Write-Host "    ⚠ $($var.Name) : Chưa set (Tùy chọn)" -ForegroundColor Yellow
    }
}

# ============================================
# 5. KIỂM TRA ĐƯỜNG DẪN WINDOWS
# ============================================
Write-Host "`n[5/6] Kiểm tra Đường dẫn Windows trong mcp.json..." -ForegroundColor Yellow

if ($mcpJsonExists -and $json.mcpServers) {
    $jsonContent = Get-Content $mcpJsonPath -Raw
    $hasForwardSlash = $jsonContent -match '[^"]/[^"]'
    $hasDoubleBackslash = $jsonContent -match '\\\\'
    
    if ($hasForwardSlash -or $hasDoubleBackslash) {
        Write-Host "  ✓ Đường dẫn có format đúng (forward slash hoặc double backslash)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Không tìm thấy đường dẫn Windows trong file" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ Không thể kiểm tra (file không tồn tại hoặc JSON sai)" -ForegroundColor Yellow
}

# ============================================
# 6. TẠO FILE MCP.JSON MẪU (NẾU DÙNG -Fix)
# ============================================
Write-Host "`n[6/6] Tạo File mcp.json Mẫu..." -ForegroundColor Yellow

if ($Fix) {
    if (-not $mcpJsonExists) {
        Write-Host "  → Tạo file mcp.json mẫu..." -ForegroundColor Cyan
        
        $sampleJson = @{
            mcpServers = @{
                "supabase-official" = @{
                    command = "npx"
                    args = @("-y", "@supabase/mcp-server-supabase@latest")
                    env = @{
                        SUPABASE_ACCESS_TOKEN = "YOUR_ACCESS_TOKEN_HERE"
                        SUPABASE_PROJECT_REF = "YOUR_PROJECT_REF_HERE"
                    }
                }
                "supabase" = @{
                    command = "supabase-mcp-server"
                    env = @{
                        QUERY_API_KEY = "YOUR_QUERY_API_KEY_FROM_THEQUERY_DEV"
                        SUPABASE_PROJECT_REF = "YOUR_PROJECT_REF"
                        SUPABASE_DB_PASSWORD = "YOUR_DB_PASSWORD"
                        SUPABASE_REGION = "us-east-1"
                        SUPABASE_ACCESS_TOKEN = "YOUR_ACCESS_TOKEN"
                        SUPABASE_SERVICE_ROLE_KEY = "YOUR_SERVICE_ROLE_KEY"
                    }
                }
                "github.com/upstash/context7-mcp" = @{
                    command = "npx"
                    args = @("-y", "@upstash/context7-mcp@latest")
                    env = @{
                        CONTEXT7_API_KEY = "YOUR_CONTEXT7_API_KEY"
                    }
                }
                "github.com/zcaceres/fetch-mcp" = @{
                    command = "npx"
                    args = @("-y", "@zcaceres/fetch-mcp@latest")
                }
                "github" = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-github@latest")
                    env = @{
                        GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_YOUR_TOKEN_HERE"
                    }
                }
                "filesystem" = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-filesystem@latest", "D:\\code\\Flutter_Android\\AI_LMS_PRD")
                }
                "memory" = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-memory@latest")
                }
            }
        } | ConvertTo-Json -Depth 10
        
        # Tạo thư mục nếu chưa có
        $mcpJsonDir = Split-Path $mcpJsonPath -Parent
        if (-not (Test-Path $mcpJsonDir)) {
            New-Item -ItemType Directory -Force -Path $mcpJsonDir | Out-Null
        }
        
        $sampleJson | Out-File -FilePath $mcpJsonPath -Encoding UTF8
        Write-Host "  ✓ Đã tạo file mcp.json mẫu tại: $mcpJsonPath" -ForegroundColor Green
        Write-Host "    → Vui lòng chỉnh sửa và điền thông tin thực tế" -ForegroundColor Yellow
    } else {
        Write-Host "  ⚠ File đã tồn tại, không tạo mới" -ForegroundColor Yellow
        Write-Host "    → Nếu muốn tạo lại, hãy backup và xóa file cũ trước" -ForegroundColor Gray
    }
} else {
    Write-Host "  ℹ Dùng -Fix để tự động tạo file mcp.json mẫu" -ForegroundColor Cyan
}

# ============================================
# TỔNG KẾT
# ============================================
Write-Host "`n=== Tổng kết ===" -ForegroundColor Cyan

$issues = @()
if (-not $prereqResults["Node.js"].Installed) { $issues += "Node.js chưa cài đặt" }
if (-not $prereqResults["npx"].Installed) { $issues += "npx không hoạt động" }
if (-not $mcpJsonExists) { $issues += "File mcp.json không tồn tại" }

if ($issues.Count -eq 0) {
    Write-Host "✓ Không phát hiện lỗi nghiêm trọng" -ForegroundColor Green
    Write-Host "  → Nếu vẫn gặp lỗi, hãy:" -ForegroundColor Yellow
    Write-Host "    1. Mở Developer Tools (Ctrl+Shift+I) và xem log" -ForegroundColor Gray
    Write-Host "    2. Restart Cursor hoàn toàn" -ForegroundColor Gray
    Write-Host "    3. Kiểm tra log trong Console với filter 'mcp'" -ForegroundColor Gray
} else {
    Write-Host "✗ Phát hiện các vấn đề sau:" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Red
    }
    Write-Host "`n→ Sửa các vấn đề trên trước khi tiếp tục" -ForegroundColor Yellow
}

Write-Host "`n=== Hướng dẫn Tiếp theo ===" -ForegroundColor Cyan
Write-Host "1. Mở Developer Tools: Ctrl+Shift+I" -ForegroundColor White
Write-Host "2. Filter log: 'mcp' trong Console" -ForegroundColor White
Write-Host "3. Restart Cursor và xem log khởi động" -ForegroundColor White
Write-Host "4. Copy log và gửi cho AI Agent để phân tích" -ForegroundColor White
Write-Host "`nXem chi tiết tại: docs/guides/tools/MCP_CONNECTION_CLOSED_FIX.md" -ForegroundColor Cyan
