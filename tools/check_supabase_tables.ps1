# Script để kiểm tra các tables trong Supabase database
# Sử dụng Supabase REST API

param(
    [string]$SupabaseUrl = "https://vazhgunhcjdwlkbslroc.supabase.co",
    [string]$SupabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhemhndW5oY2pkd2xrYnNscm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxMTI3NTksImV4cCI6MjA4MDY4ODc1OX0.D-O3FbXF46mVEga152RmumAkmqS54_A-L7tFa6UBi0c"
)

Write-Host "[*] Dang kiem tra cac tables trong Supabase database..." -ForegroundColor Cyan
Write-Host "Project URL: $SupabaseUrl" -ForegroundColor Gray
Write-Host ""

# Danh sách tables từ documentation
$expectedTables = @(
    "profiles",
    "schools",
    "classes",
    "class_members",
    "groups",
    "group_members",
    "assignments",
    "assignment_questions",
    "questions",
    "submissions",
    "work_sessions",
    "ai_queue",
    "student_skill_mastery",
    "notifications",
    "teacher_notes"
)

$headers = @{
    "apikey" = $SupabaseAnonKey
    "Authorization" = "Bearer $SupabaseAnonKey"
    "Content-Type" = "application/json"
}

$foundTables = @()
$notFoundTables = @()

Write-Host "[*] Ket qua kiem tra:" -ForegroundColor Yellow
Write-Host ""

foreach ($table in $expectedTables) {
    try {
        $url = "$SupabaseUrl/rest/v1/$table?limit=1"
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
        
        Write-Host "[OK] $table" -ForegroundColor Green
        $foundTables += $table
    }
    catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        if ($statusCode -eq 404) {
            Write-Host "[X] $table (404 - Table khong ton tai)" -ForegroundColor Red
            $notFoundTables += $table
        }
        elseif ($statusCode -eq 401) {
            Write-Host "[!] $table (401 - Loi authentication)" -ForegroundColor Yellow
        }
        else {
            $errorMsg = if ($statusCode) { "Loi: $statusCode" } else { $_.Exception.Message }
            Write-Host "[!] $table ($errorMsg)" -ForegroundColor Yellow
            $notFoundTables += $table
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Gray
Write-Host "[*] Tong ket:" -ForegroundColor Cyan
Write-Host "  [OK] Tables ton tai: $($foundTables.Count)" -ForegroundColor Green
Write-Host "  [X] Tables khong ton tai: $($notFoundTables.Count)" -ForegroundColor Red
Write-Host ""

if ($notFoundTables.Count -gt 0) {
    Write-Host "[!] Cac tables chua duoc tao:" -ForegroundColor Yellow
    foreach ($table in $notFoundTables) {
        Write-Host "    - $table" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "[*] Goi y: Chay migrations de tao cac tables nay" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[*] De xem chi tiet tables bang MCP Supabase:" -ForegroundColor Cyan
Write-Host "   1. Cau hinh MCP Supabase theo huong dan trong docs/mcp/SUPABASE_MCP_SETUP.md" -ForegroundColor Gray
Write-Host "   2. Sau do hoi AI: 'Dung MCP Supabase de list tat ca tables'" -ForegroundColor Gray
