# Script de lay thong tin tat ca cac bang tu Supabase su dung MCP
# Chay: powershell -ExecutionPolicy Bypass -File tools\get_supabase_tables_via_mcp.ps1

$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Lay thong tin Tables tu Supabase MCP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRef = "vazhgunhcjdwlkbslroc"
$accessToken = "sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596"

# Set environment variables
$env:SUPABASE_ACCESS_TOKEN = $accessToken
$env:SUPABASE_PROJECT_REF = $projectRef

Write-Host "Dang kiem tra ket noi MCP server..." -ForegroundColor Yellow

# Test MCP server
Write-Host "Kiem tra @supabase/mcp-server-supabase..." -ForegroundColor White
try {
    $null = npx -y @supabase/mcp-server-supabase@latest --project-ref $projectRef --help 2>&1
    Write-Host "OK MCP server co san" -ForegroundColor Green
} catch {
    Write-Host "Loi khi kiem tra MCP server: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HUONG DAN SU DUNG MCP TRONG CURSOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "De su dung Supabase MCP trong Cursor:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Dam bao MCP server da duoc cau hinh trong Cursor:" -ForegroundColor White
Write-Host "   File: c:/Users/anhhuy/.cursor/mcp.json" -ForegroundColor Gray
Write-Host "   OK Da co cau hinh supabase-official" -ForegroundColor Green
Write-Host ""
Write-Host "2. Restart Cursor hoan toan:" -ForegroundColor White
Write-Host "   - Dong tat ca cua so Cursor" -ForegroundColor Gray
Write-Host "   - Mo lai Cursor" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Kiem tra MCP server da load:" -ForegroundColor White
Write-Host "   - Mo Developer Tools (Ctrl+Shift+I)" -ForegroundColor Gray
Write-Host "   - Vao Console tab" -ForegroundColor Gray
Write-Host "   - Tim log: '[MCP] Starting server: supabase-official'" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Sau khi MCP da load, ban co the hoi AI:" -ForegroundColor White
Write-Host "   'Dung MCP supabase-official de list tat ca cac tables'" -ForegroundColor Cyan
Write-Host "   'Su dung supabase-official MCP de get_tables'" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CAC TOOLS CO SAN TRONG SUPABASE MCP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Theo cau hinh autoApprove, cac tools sau co san:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  - get_tables - List tat ca tables" -ForegroundColor White
Write-Host "  - get_table - Lay thong tin mot table cu the" -ForegroundColor White
Write-Host "  - get_table_columns - Lay danh sach columns cua table" -ForegroundColor White
Write-Host "  - get_table_rows - Lay rows tu table" -ForegroundColor White
Write-Host "  - get_table_row - Lay mot row cu the" -ForegroundColor White
Write-Host "  - get_table_row_by_id - Lay row theo ID" -ForegroundColor White
Write-Host "  - list_extensions - List PostgreSQL extensions" -ForegroundColor White
Write-Host "  - list_migrations - List migrations da apply" -ForegroundColor White
Write-Host "  - apply_migration - Apply migration moi" -ForegroundColor White
Write-Host "  - get_logs - Lay logs tu services" -ForegroundColor White
Write-Host "  - get_advisors - Lay security/performance advisors" -ForegroundColor White
Write-Host "  - generate_typescript_types - Generate TypeScript types" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "THONG TIN PROJECT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project Reference: $projectRef" -ForegroundColor White
Write-Host "Access Token: $($accessToken.Substring(0, 20))..." -ForegroundColor White
Write-Host ""
Write-Host "Dashboard URL: https://supabase.com/dashboard/project/$projectRef" -ForegroundColor Cyan
Write-Host ""
