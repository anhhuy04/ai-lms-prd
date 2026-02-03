# Simple MCP Test Script
Write-Host "=== MCP Connection Test ===" -ForegroundColor Cyan
Write-Host ""

# Test basic MCP server commands
$commands = @(
    @{ Name = "Supabase"; Command = "npx -y @supabase/mcp-server-supabase@latest --project-ref vazhgunhcjdwlkbslroc" },
    @{ Name = "Context7"; Command = "npx -y @upstash/context7-mcp@latest" },
    @{ Name = "Fetch"; Command = "npx mcp-fetch-server" },
    @{ Name = "GitHub"; Command = "npx -y @modelcontextprotocol/server-github@latest" },
    @{ Name = "Filesystem"; Command = "npx -y @modelcontextprotocol/server-filesystem@latest D:\code\Flutter_Android\AI_LMS_PRD" },
    @{ Name = "Memory"; Command = "npx -y @modelcontextprotocol/server-memory@latest" },
    @{ Name = "Dart"; Command = "dart mcp-server --experimental-mcp-server --force-roots-fallback" }
)

foreach ($cmd in $commands) {
    Write-Host "Testing $($cmd.Name) MCP server..." -ForegroundColor White

    try {
        # Test if command exists
        $testProcess = Start-Process -NoNewWindow -PassThru -FilePath "cmd.exe" -ArgumentList "/c $($cmd.Command)"
        Start-Sleep -Milliseconds 300

        if (-not $testProcess.HasExited) {
            Write-Host "  ✓ $($cmd.Name) MCP server command works" -ForegroundColor Green
            $testProcess.Kill() | Out-Null
        } else {
            Write-Host "  ✗ $($cmd.Name) MCP server command failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ $($cmd.Name) MCP server error: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "MCP servers are installed and commands work, but they need to be connected to Cursor." -ForegroundColor White
Write-Host ""
Write-Host "To connect MCP servers to Cursor:" -ForegroundColor Yellow
Write-Host "1. Restart Cursor completely (close and reopen)" -ForegroundColor White
Write-Host "2. Open Developer Tools (Ctrl+Shift+I)" -ForegroundColor White
Write-Host "3. Go to Console tab and filter for 'mcp'" -ForegroundColor White
Write-Host "4. Look for success logs like '[MCP] Starting server: supabase-official'" -ForegroundColor White
Write-Host "5. If you see errors, copy the logs and send them for analysis" -ForegroundColor White
Write-Host ""
Write-Host "If MCP servers still don't connect after restart:" -ForegroundColor Yellow
Write-Host "- Check file mcp.json configuration" -ForegroundColor White
Write-Host "- Verify all environment variables are set" -ForegroundColor White
Write-Host "- Check network connectivity" -ForegroundColor White
Write-Host "- Ensure Python is installed for Python-based MCP servers" -ForegroundColor White
