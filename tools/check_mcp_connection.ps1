# Simple MCP Connection Check Script
Write-Host "=== MCP Connection Check ===" -ForegroundColor Cyan
Write-Host ""

# Check if MCP servers are running by testing direct commands
$servers = @{
    "Supabase" = "npx -y @supabase/mcp-server-supabase@latest --project-ref vazhgunhcjdwlkbslroc"
    "Context7" = "npx -y @upstash/context7-mcp@latest"
    "Fetch" = "npx -y mcp-fetch-server"
    "GitHub" = "npx -y @modelcontextprotocol/server-github@latest"
    "Filesystem" = "npx -y @modelcontextprotocol/server-filesystem@latest D:\code\Flutter_Android\AI_LMS_PRD"
    "Memory" = "npx -y @modelcontextprotocol/server-memory@latest"
    "Dart" = "dart mcp-server --experimental-mcp-server --force-roots-fallback"
}

Write-Host "Testing MCP server commands..." -ForegroundColor Yellow
Write-Host ""

foreach ($name in $servers.Keys) {
    $command = $servers[$name]
    Write-Host "Testing $name MCP server..." -ForegroundColor White

    try {
        # Start the process and wait briefly
        $process = Start-Process -NoNewWindow -PassThru -FilePath "cmd.exe" -ArgumentList "/c $command"
        Start-Sleep -Milliseconds 500

        if (-not $process.HasExited) {
            Write-Host "  OK $name MCP server started successfully" -ForegroundColor Green
            $process.Kill()
        } else {
            Write-Host "  FAIL $name MCP server failed to start" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ERROR $name MCP server error: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Restart Cursor completely" -ForegroundColor White
Write-Host "2. Open Developer Tools (Ctrl+Shift+I)" -ForegroundColor White
Write-Host "3. Go to Console tab and filter for 'mcp'" -ForegroundColor White
Write-Host "4. Look for success logs like '[MCP] Starting server: supabase-official'" -ForegroundColor White
Write-Host "5. If you see errors, copy the logs and send them for analysis" -ForegroundColor White
Write-Host ""
Write-Host "Common issues:" -ForegroundColor Yellow
Write-Host "- MCP servers not loaded (need restart)" -ForegroundColor White
Write-Host "- Missing environment variables" -ForegroundColor White
Write-Host "- Network connectivity issues" -ForegroundColor White
Write-Host "- Python not installed (for some MCP servers)" -ForegroundColor White
Write-Host ""
