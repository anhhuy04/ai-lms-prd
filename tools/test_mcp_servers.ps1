$ErrorActionPreference = 'Stop'

Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'MCP SERVERS TEST SCRIPT' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

function Test-Command {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][ScriptBlock]$Cmd
    )

    Write-Host $Label -ForegroundColor Yellow
    try {
        $output = & $Cmd 2>&1
        if ($LASTEXITCODE -eq 0 -or ($output -match 'usage|help|options')) {
            Write-Host '  OK' -ForegroundColor Green
        } else {
            Write-Host '  FAIL' -ForegroundColor Red
            Write-Host ("  Output: {0}" -f ($output | Out-String)) -ForegroundColor Red
        }
    } catch {
        Write-Host '  FAIL (exception)' -ForegroundColor Red
        Write-Host ("  {0}" -f $_) -ForegroundColor Red
    }
    Write-Host ''
}

Test-Command '[1/6] Node + npx' { node --version; npx --version }
Test-Command '[2/6] Supabase MCP (@supabase/mcp-server-supabase)' { npx -y @supabase/mcp-server-supabase@latest --help }
Test-Command '[3/6] Context7 MCP (@upstash/context7-mcp)' { npx -y @upstash/context7-mcp@latest --help }
Test-Command '[4/6] Fetch MCP (mcp-fetch-server)' { npx -y mcp-fetch-server --help }
Test-Command '[5/6] GitHub MCP (@modelcontextprotocol/server-github)' { npx -y @modelcontextprotocol/server-github@latest --help }
Test-Command '[6/6] Memory MCP (@modelcontextprotocol/server-memory)' { npx -y @modelcontextprotocol/server-memory@latest --help }

Write-Host 'Done. This only verifies spawnability from CLI.' -ForegroundColor Cyan
