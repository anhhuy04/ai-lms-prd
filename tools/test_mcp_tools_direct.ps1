# Script test MCP server truc tiep de xem co expose tools khong
# Chay: powershell -ExecutionPolicy Bypass -File tools\test_mcp_tools_direct.ps1

$ErrorActionPreference = 'Continue'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST MCP SERVER TRUC TIEP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRef = "vazhgunhcjdwlkbslroc"
$accessToken = "sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596"

# Set environment variables
$env:SUPABASE_ACCESS_TOKEN = $accessToken
$env:SUPABASE_PROJECT_REF = $projectRef

Write-Host "Dang chay MCP server trong stdio mode..." -ForegroundColor Yellow
Write-Host "Luu y: MCP server se chay trong stdio mode, can gui JSON-RPC messages" -ForegroundColor Gray
Write-Host ""
Write-Host "De test MCP server, ban can:" -ForegroundColor Yellow
Write-Host "1. Mo terminal khac" -ForegroundColor White
Write-Host "2. Chay: npx -y @supabase/mcp-server-supabase@latest --project-ref $projectRef" -ForegroundColor Cyan
Write-Host "3. Gui JSON-RPC message de list tools:" -ForegroundColor White
Write-Host ""
Write-Host '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' -ForegroundColor Gray
Write-Host ""
Write-Host "HOAC su dung Cursor Developer Tools de xem MCP logs" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HUONG DAN KIEM TRA TRONG CURSOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Mo Cursor Developer Tools (Ctrl+Shift+I)" -ForegroundColor White
Write-Host "2. Vao Console tab" -ForegroundColor White
Write-Host "3. Filter: 'mcp' hoac 'tool'" -ForegroundColor White
Write-Host "4. Tim cac log:" -ForegroundColor White
Write-Host "   - '[MCP] Starting server: supabase-official'" -ForegroundColor Cyan
Write-Host "   - '[MCP] Tools available: get_tables, get_table, ...'" -ForegroundColor Green
Write-Host "   - Hoac bat ky error nao" -ForegroundColor Red
Write-Host ""
Write-Host "5. Copy log va gui cho AI Agent de phan tich" -ForegroundColor Yellow
Write-Host ""
