# Script tạo file mcp.json với cấu hình đúng cho Windows
# Chạy: powershell -ExecutionPolicy Bypass -File tools\create_mcp_config.ps1

$mcpJsonPath = "$env:APPDATA\Cursor\mcp.json"
$projectPath = "D:\code\Flutter_Android\AI_LMS_PRD"

Write-Host "=== Tạo File mcp.json ===" -ForegroundColor Cyan

# Tạo thư mục nếu chưa có
$mcpJsonDir = Split-Path $mcpJsonPath -Parent
if (-not (Test-Path $mcpJsonDir)) {
    New-Item -ItemType Directory -Force -Path $mcpJsonDir | Out-Null
    Write-Host "✓ Đã tạo thư mục: $mcpJsonDir" -ForegroundColor Green
}

# Kiểm tra file đã tồn tại chưa
if (Test-Path $mcpJsonPath) {
    Write-Host "⚠ File đã tồn tại: $mcpJsonPath" -ForegroundColor Yellow
    $backup = "$mcpJsonPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $mcpJsonPath $backup
    Write-Host "✓ Đã backup file cũ: $backup" -ForegroundColor Green
}

# Tạo nội dung mcp.json
$mcpConfig = @{
    mcpServers = @{
        "supabase-official" = @{
            command = "npx"
            args = @("-y", "@supabase/mcp-server-supabase@latest")
            env = @{
                SUPABASE_ACCESS_TOKEN = "YOUR_ACCESS_TOKEN_HERE"
                SUPABASE_PROJECT_REF = "YOUR_PROJECT_REF_HERE"
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
            args = @("-y", "@modelcontextprotocol/server-filesystem@latest", $projectPath)
        }
        "memory" = @{
            command = "npx"
            args = @("-y", "@modelcontextprotocol/server-memory@latest")
        }
    }
}

# Convert to JSON và lưu file
$jsonContent = $mcpConfig | ConvertTo-Json -Depth 10
$jsonContent | Out-File -FilePath $mcpJsonPath -Encoding UTF8

Write-Host "✓ Đã tạo file mcp.json tại: $mcpJsonPath" -ForegroundColor Green
Write-Host ""
Write-Host "⚠ QUAN TRỌNG: Vui lòng chỉnh sửa file và điền các giá trị thực tế:" -ForegroundColor Yellow
Write-Host "  - SUPABASE_ACCESS_TOKEN" -ForegroundColor Gray
Write-Host "  - SUPABASE_PROJECT_REF" -ForegroundColor Gray
Write-Host "  - CONTEXT7_API_KEY (nếu cần)" -ForegroundColor Gray
Write-Host "  - GITHUB_PERSONAL_ACCESS_TOKEN (nếu cần)" -ForegroundColor Gray
Write-Host ""
Write-Host "Mở file để chỉnh sửa:" -ForegroundColor Cyan
$notepadCmd = "notepad `"$mcpJsonPath`""
$codeCmd = "code `"$mcpJsonPath`""
Write-Host "  $notepadCmd" -ForegroundColor White
Write-Host "Hoặc:" -ForegroundColor Cyan
Write-Host "  $codeCmd" -ForegroundColor White
