# Script debug MCP Supabase khi da sang xanh nhung khong dung duoc
# Chay: powershell -ExecutionPolicy Bypass -File tools\debug_mcp_supabase.ps1

$ErrorActionPreference = 'Continue'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEBUG MCP SUPABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRef = "vazhgunhcjdwlkbslroc"
$accessToken = "sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596"

# Set environment variables
$env:SUPABASE_ACCESS_TOKEN = $accessToken
$env:SUPABASE_PROJECT_REF = $projectRef

Write-Host "[1/6] Kiem tra Node.js va npx..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    $npxVersion = npx --version 2>&1
    Write-Host "  OK Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "  OK npx: $npxVersion" -ForegroundColor Green
} catch {
    Write-Host "  LOI: Node.js hoac npx chua duoc cai dat" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/6] Test MCP server co the chay duoc khong..." -ForegroundColor Yellow
try {
    Write-Host "  Dang chay: npx -y @supabase/mcp-server-supabase@latest --project-ref $projectRef --help" -ForegroundColor Gray
    $testOutput = npx -y @supabase/mcp-server-supabase@latest --project-ref $projectRef --help 2>&1 | Out-String
    
    if ($LASTEXITCODE -eq 0 -or $testOutput -match "usage|help|version|options") {
        Write-Host "  OK MCP server co the chay duoc" -ForegroundColor Green
    } else {
        Write-Host "  CANH BAO: MCP server co the khong chay dung" -ForegroundColor Yellow
        Write-Host "  Output: $testOutput" -ForegroundColor Gray
    }
} catch {
    Write-Host "  LOI: Khong the chay MCP server: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/6] Kiem tra cau hinh mcp.json..." -ForegroundColor Yellow
$mcpJsonPath = "$env:APPDATA\Cursor\mcp.json"
if (Test-Path $mcpJsonPath) {
    Write-Host "  OK File ton tai: $mcpJsonPath" -ForegroundColor Green
    
    try {
        $mcpConfig = Get-Content $mcpJsonPath -Raw | ConvertFrom-Json
        $supabaseConfig = $mcpConfig.mcpServers.'supabase-official'
        
        if ($supabaseConfig) {
            Write-Host "  OK Cau hinh supabase-official ton tai" -ForegroundColor Green
            Write-Host "  Command: $($supabaseConfig.command)" -ForegroundColor Gray
            Write-Host "  Args: $($supabaseConfig.args -join ' ')" -ForegroundColor Gray
            
            if ($supabaseConfig.env.SUPABASE_ACCESS_TOKEN) {
                $tokenPreview = $supabaseConfig.env.SUPABASE_ACCESS_TOKEN.Substring(0, [Math]::Min(20, $supabaseConfig.env.SUPABASE_ACCESS_TOKEN.Length))
                Write-Host "  OK Access Token: $tokenPreview..." -ForegroundColor Green
            } else {
                Write-Host "  CANH BAO: SUPABASE_ACCESS_TOKEN khong co trong env" -ForegroundColor Yellow
            }
            
            if ($supabaseConfig.args -contains $projectRef) {
                Write-Host "  OK Project Ref dung: $projectRef" -ForegroundColor Green
            } else {
                Write-Host "  CANH BAO: Project Ref co the sai trong args" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  LOI: Khong tim thay cau hinh supabase-official" -ForegroundColor Red
        }
    } catch {
        Write-Host "  LOI: Khong the parse JSON: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  LOI: File khong ton tai: $mcpJsonPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "[4/6] Test ket noi truc tiep den Supabase..." -ForegroundColor Yellow
try {
    $supabaseUrl = "https://$projectRef.supabase.co"
    Write-Host "  Dang test ket noi den: $supabaseUrl" -ForegroundColor Gray
    
    $response = Invoke-WebRequest -Uri "$supabaseUrl/rest/v1/" -Method GET -TimeoutSec 10 -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401) {
        Write-Host "  OK Ket noi den Supabase thanh cong (Status: $($response.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host "  CANH BAO: Status code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  CANH BAO: Khong the ket noi den Supabase: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[5/6] Kiem tra MCP server co expose tools khong..." -ForegroundColor Yellow
Write-Host "  (Can kiem tra trong Cursor Developer Tools Console)" -ForegroundColor Gray
Write-Host "  Mo Developer Tools (Ctrl+Shift+I) va tim log:" -ForegroundColor Gray
Write-Host "    - '[MCP] Starting server: supabase-official'" -ForegroundColor Cyan
Write-Host "    - '[MCP] Tools available: ...'" -ForegroundColor Cyan
Write-Host "    - Hoac bat ky error nao" -ForegroundColor Red

Write-Host ""
Write-Host "[6/6] Cac buoc tiep theo..." -ForegroundColor Yellow
Write-Host ""
Write-Host "NEU MCP SANG XANH NHUNG KHONG DUNG DUOC:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Mo Developer Tools (Ctrl+Shift+I)" -ForegroundColor White
Write-Host "2. Vao Console tab" -ForegroundColor White
Write-Host "3. Filter: 'mcp' hoac 'supabase'" -ForegroundColor White
Write-Host "4. Tim cac log loi hoac warning" -ForegroundColor White
Write-Host "5. Copy log va gui cho AI Agent de phan tich" -ForegroundColor White
Write-Host ""
Write-Host "HOAC thu cach khac:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Restart Cursor hoan toan (dong tat ca cua so)" -ForegroundColor White
Write-Host "2. Mo lai Cursor" -ForegroundColor White
Write-Host "3. Doi 10-15 giay de MCP servers load" -ForegroundColor White
Write-Host "4. Thu lai yeu cau AI su dung MCP" -ForegroundColor White
Write-Host ""
Write-Host "HOAC test MCP server truc tiep:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  npx -y @supabase/mcp-server-supabase@latest --project-ref $projectRef" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
